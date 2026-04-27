extends Node2D

@export var enemy_scene: PackedScene = preload("res://scenes/enemy.tscn")
@export var spawn_interval: float = 1.0
@export var max_enemies: int = 30

@onready var player: CharacterBody2D = $Player

func _ready() -> void:
	var spawn_timer = Timer.new()
	spawn_timer.wait_time = spawn_interval
	spawn_timer.autostart = true
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(spawn_timer)

func _on_spawn_timer_timeout() -> void:
	if get_tree().get_nodes_in_group("enemies").size() < max_enemies:
		spawn_enemy()

func spawn_enemy() -> void:
	var enemy = enemy_scene.instantiate()
	
	# Calculate spawn position outside the screen relative to player
	var spawn_pos = get_random_spawn_position()
	enemy.global_position = spawn_pos
	
	# Scale it up a bit as seen in main.tscn
	enemy.scale = Vector2(4, 4)
	
	add_child(enemy)

func get_random_spawn_position() -> Vector2:
	if not player:
		return Vector2.ZERO
		
	var viewport_size = get_viewport_rect().size
	# Distance slightly larger than the screen diagonal to ensure it's outside
	var spawn_radius = viewport_size.length() / 1.5 
	
	var angle = randf() * TAU
	return player.global_position + Vector2.from_angle(angle) * spawn_radius
