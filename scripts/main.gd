extends Node2D

@export var SpecialZ: PackedScene = preload("res://scenes/special.tscn")
@export var NormalZ: PackedScene = preload("res://scenes/normal.tscn")
@export var BruteZ: PackedScene = preload("res://scenes/brute.tscn")

@export var max_enemies: int = 200

var music_player: AudioStreamPlayer

@onready var player: CharacterBody2D = $Player

enum State { TITLE, PLAYING, GAMEOVER, UPGRADE }
var current_state = State.TITLE

var survival_time: float = 0.0
var timer_label: Label

var enemy_health_multiplier: float = 1.0
var last_health_increase_minute: int = 0

var title_screen_instance: Control
var end_screen_instance: Control
var upgrade_screen_instance: Control

@export var TitleScreenScene: PackedScene = preload("res://scenes/title_screen.tscn")
@export var EndScreenScene: PackedScene = preload("res://scenes/end_screen.tscn")
@export var UpgradeScreenScene: PackedScene = preload("res://scenes/upgrade_screen.tscn")
@export var StatsWindowScene: PackedScene = preload("res://scenes/ui/stats_window.tscn")

@onready var spawn_timer: Timer = Timer.new()

var stats_window_instance: Control

func _ready() -> void:
	# Setup Spawn Timer
	spawn_timer.wait_time = 2.5
	spawn_timer.autostart = false
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(spawn_timer)
	
	# Instantiate Menus
	title_screen_instance = TitleScreenScene.instantiate()
	var title_canvas = CanvasLayer.new()
	title_canvas.layer = 100
	title_canvas.add_child(title_screen_instance)
	add_child(title_canvas)
	title_screen_instance.start_game.connect(start_game)
	
	end_screen_instance = EndScreenScene.instantiate()
	# Attach script manually in case it's not saved in the tscn
	end_screen_instance.set_script(preload("res://scripts/end_screen.gd"))
	end_screen_instance._ready() # Force ready since we just attached the script
	end_screen_instance.restart_game.connect(reset_game)
	
	var end_canvas = CanvasLayer.new()
	end_canvas.layer = 100
	end_canvas.add_child(end_screen_instance)
	add_child(end_canvas)
	
	upgrade_screen_instance = UpgradeScreenScene.instantiate()
	upgrade_screen_instance.set_script(preload("res://scripts/upgrade_screen.gd"))
	upgrade_screen_instance._ready()
	upgrade_screen_instance.upgrade_selected.connect(_on_upgrade_selected)
	upgrade_screen_instance.visible = false
	
	var upgrade_canvas = CanvasLayer.new()
	upgrade_canvas.layer = 110
	upgrade_canvas.add_child(upgrade_screen_instance)
	add_child(upgrade_canvas)
	
	# Stats Window setup
	stats_window_instance = StatsWindowScene.instantiate()
	var stats_canvas = CanvasLayer.new()
	stats_canvas.layer = 120
	stats_canvas.add_child(stats_window_instance)
	add_child(stats_canvas)
	
	# Connect to player level up
	player.leveled_up.connect(_on_player_leveled_up)

	# Setup music player
	music_player = AudioStreamPlayer.new()
	music_player.stream = load("res://assets/audio/home_screen.mp3")
	music_player.volume_db = 0.0
	music_player.loop = true
	add_child(music_player)
	print("Music player created, stream: ", music_player.stream)

	process_mode = Node.PROCESS_MODE_ALWAYS
	player.process_mode = Node.PROCESS_MODE_PAUSABLE
	
	# Setup Timer UI
	var timer_canvas = CanvasLayer.new()
	timer_canvas.layer = 90
	timer_label = Label.new()
	timer_label.text = "00:00"
	timer_label.add_theme_font_size_override("font_size", 40)
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	timer_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	timer_canvas.add_child(timer_label)
	add_child(timer_canvas)
	
	# Initial State
	enter_title_screen()

func _input(event):
	if event.is_action_pressed("toggle_stats"):
		toggle_stats_window()

func toggle_stats_window():
	stats_window_instance.visible = !stats_window_instance.visible
	
	if stats_window_instance.visible:
		get_tree().paused = true
		stats_window_instance.update_stats(player)
	else:
		# Only unpause if the upgrade screen is also not visible
		if not upgrade_screen_instance.visible:
			get_tree().paused = false
	
	spawn_timer.paused = stats_window_instance.visible

func _on_spawn_timer_timeout() -> void:
	if current_state != State.PLAYING: return
	
	var group_size = 4 + int(survival_time / 30)
	
	for i in range(group_size):
		if get_tree().get_nodes_in_group("enemies").size() < max_enemies:
			spawn_enemy()

func spawn_enemy() -> void:
	var rand_val = randi() % 3
	var enemy_scene_to_spawn
	
	if rand_val == 0:
		enemy_scene_to_spawn = NormalZ
	elif rand_val == 1:
		enemy_scene_to_spawn = BruteZ
	else:
		enemy_scene_to_spawn = SpecialZ
		
	var enemy = enemy_scene_to_spawn.instantiate()
	
	# Calculate spawn position outside the screen relative to player
	var spawn_pos = get_random_spawn_position()
	enemy.global_position = spawn_pos
	
	# Apply health scaling
	if "hp" in enemy:
		enemy.hp *= enemy_health_multiplier
		
	add_child(enemy)

func get_random_spawn_position() -> Vector2:
	if not player:
		return Vector2.ZERO
		
	var viewport_size = get_viewport_rect().size
	# Distance slightly larger than the screen diagonal to ensure it's outside
	var spawn_radius = viewport_size.length() / 1.8 
	
	var angle = randf() * TAU
	return player.global_position + Vector2.from_angle(angle) * spawn_radius

func enter_title_screen():
	current_state = State.TITLE
	title_screen_instance.visible = true
	end_screen_instance.visible = false
	timer_label.visible = false
	player.hide_hud()
	player.visible = false
	player.global_position = get_viewport_rect().size / 2.0
	
	player.set_physics_process(false)
	spawn_timer.stop()

func start_game():
	current_state = State.PLAYING
	survival_time = 0.0
	title_screen_instance.visible = false
	end_screen_instance.visible = false

	if music_player:
		music_player.play()
		print("Music started playing")

	player.show_hud()
	player.visible = true
	player.is_active = true
	player.set_physics_process(true)
	timer_label.visible = true
	spawn_timer.start()

func reset_game():
	get_tree().paused = false
	# Clear the board
	get_tree().call_group("enemies", "queue_free")
	get_tree().call_group("bullet", "queue_free")
	
	enemy_health_multiplier = 1.0
	last_health_increase_minute = 0
	
	player.reset()
	start_game()

func game_over():
	current_state = State.GAMEOVER
	player.hide_hud()
	player.set_physics_process(false)
	spawn_timer.stop()
	
	# Clear the board
	get_tree().call_group("enemies", "queue_free")
	get_tree().call_group("bullet", "queue_free")
	
	timer_label.visible = false
	end_screen_instance.visible = true
	
	if end_screen_instance.has_method("set_score"):
		end_screen_instance.set_score(get_formatted_time())

func _on_player_leveled_up(new_level: int):
	current_state = State.UPGRADE
	get_tree().paused = true
	upgrade_screen_instance.open_screen(player, new_level)

func _on_upgrade_selected():
	upgrade_screen_instance.visible = false
	get_tree().paused = false
	current_state = State.PLAYING

func _process(delta):
	if current_state == State.PLAYING and not get_tree().paused:
		survival_time += delta
		timer_label.text = get_formatted_time()
		
		# Health scaling logic
		var current_minute = int(survival_time / 60)
		if current_minute > last_health_increase_minute:
			last_health_increase_minute = current_minute
			enemy_health_multiplier *= 1.2
			print("Health Multiplier Increased: ", enemy_health_multiplier)

func get_formatted_time() -> String:
	var minutes = int(survival_time) / 60
	var seconds = int(survival_time) % 60
	return "%02d:%02d" % [minutes, seconds]
