extends Area2D

@export var speed := 600
var direction := Vector2.ZERO
var damage := 0.0
var penetrations_left := 1

var player: Node2D
var max_range: float = 1200.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	player = get_tree().get_first_node_in_group("player")

func initialize(dir: Vector2, dmg: float = 0.0, pen: int = 1, c_rate: float = 0.0, c_dmg: float = 2.0, spd: float = 600.0):
	direction = dir.normalized()
	rotation = direction.angle()
	speed = spd
	
	penetrations_left = pen
	
	# Pre-calculate critical hit
	if randf() <= c_rate:
		damage = dmg * c_dmg
	else:
		damage = dmg
func _process(delta):
	position += direction * speed * delta

	if player:
		if global_position.distance_to(player.global_position) > max_range:
			queue_free()
	else:
		# Fallback if player is missing
		player = get_tree().get_first_node_in_group("player")
		if not player:
			queue_free() # Or just let it fly? Let's delete to be safe.


func handle_hit():
	penetrations_left -= 1
	if penetrations_left < 0:
		queue_free()
