extends CharacterBody2D

enum State { CHASE, IDLE }

@export var speed := 50.0
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var current_state = State.CHASE
var player: Node2D = null

func _ready() -> void:
	add_to_group("enemies")
	# Small random variation in speed to make the horde look more natural
	speed = randf_range(speed * 0.8, speed * 1.2)
	player = get_tree().get_first_node_in_group("player")

func _physics_process(_delta: float) -> void:
	match current_state:
		State.CHASE:
			handle_chase()
		State.IDLE:
			velocity = Vector2.ZERO
			move_and_slide()

func handle_chase() -> void:
	if not player:
		player = get_tree().get_first_node_in_group("player")
		if not player:
			return
			
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * speed
	
	update_animation(direction)
	move_and_slide()

func update_animation(dir: Vector2) -> void:
	if dir.length() < 0.1:
		# Could play an idle animation here if available
		return
		
	if abs(dir.x) > abs(dir.y):
		if dir.x > 0:
			sprite.play("big_zombie_walk_right")
		else:
			sprite.play("big_zombie_walk_left")
	else:
		if dir.y > 0:
			sprite.play("big_zombie_walk_down")
		else:
			sprite.play("big_zombie_walk_up")
