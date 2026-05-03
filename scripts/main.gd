extends Node2D

@export var SpecialZ: PackedScene = preload("res://scenes/special.tscn")
@export var NormalZ: PackedScene = preload("res://scenes/normal.tscn")
@export var BruteZ: PackedScene = preload("res://scenes/brute.tscn")

@export var spawn_interval: float = 0.5
@export var max_enemies: int = 500

@onready var player: CharacterBody2D = $Player

enum State { TITLE, PLAYING, GAMEOVER }
var current_state = State.TITLE

var survival_time: float = 0.0
var timer_label: Label

var title_screen_instance: Control
var end_screen_instance: Control

@export var TitleScreenScene: PackedScene = preload("res://title_screen.tscn")
@export var EndScreenScene: PackedScene = preload("res://end_screen.tscn")

@onready var spawn_timer: Timer = Timer.new()

func _ready() -> void:
	# Setup Spawn Timer
	spawn_timer.wait_time = spawn_interval
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

func _on_spawn_timer_timeout() -> void:
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
	
	add_child(enemy)

func get_random_spawn_position() -> Vector2:
	if not player:
		return Vector2.ZERO
		
	var viewport_size = get_viewport_rect().size
	# Distance slightly larger than the screen diagonal to ensure it's outside
	var spawn_radius = viewport_size.length() / 1.5 
	
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
	
	player.show_hud()
	player.visible = true
	player.set_physics_process(true)
	timer_label.visible = true
	spawn_timer.start()

func reset_game():
	# Clear the board
	get_tree().call_group("enemies", "queue_free")
	get_tree().call_group("bullet", "queue_free")
	
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

func _process(delta):
	if current_state == State.PLAYING:
		survival_time += delta
		timer_label.text = get_formatted_time()

func get_formatted_time() -> String:
	var minutes = int(survival_time) / 60
	var seconds = int(survival_time) % 60
	return "%02d:%02d" % [minutes, seconds]
