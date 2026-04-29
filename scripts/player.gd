extends CharacterBody2D

@export var speed := 100
@export var acceleration := 1200
@export var friction := 800

@export var ar1: PackedScene = preload("res://scenes/gun scenes/ar1.tscn")
@export var shtgn1: PackedScene = preload("res://scenes/gun scenes/shtgn1.tscn")
@export var pstl: PackedScene = preload("res://scenes/gun scenes/pistol.tscn")

@onready var sprite: AnimatedSprite2D = $Body
@onready var weapon_socket: Marker2D = $WeaponSocket

var current_weapon: Node2D
var input_dir = Vector2.ZERO
# Track the last direction the player moved (defaulting to right)
var last_direction = "right"

func _ready():
	add_to_group("player")
	equip_weapon(ar1)

func _physics_process(delta):
	handle_movement()
	handle_aim()

func handle_movement():
	input_dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_dir.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")

	input_dir = input_dir.normalized()

	# Update the last_direction based on mouse position
	var mouse_pos = get_global_mouse_position()
	if mouse_pos.x > global_position.x:
		last_direction = "right"
	else:
		last_direction = "left"

	velocity = input_dir * speed
	move_and_slide()

	update_sprite(input_dir)


func handle_aim():
	if current_weapon == null:
		return

	var mouse_pos = get_global_mouse_position()
	
	if current_weapon.has_method("aim"):
		current_weapon.aim(mouse_pos)


func _input(event):
	if event.is_action_pressed("shoot"):
		if current_weapon:
			current_weapon.fire()


func equip_weapon(scene: PackedScene):
	if current_weapon:
		current_weapon.queue_free()

	current_weapon = scene.instantiate()

	weapon_socket.add_child(current_weapon)

	# Give weapon a reference to the player
	if current_weapon.has_method("initialize"):
		current_weapon.initialize(self)

func update_sprite(dir):
	if dir.length() > 0:
		# Playing "run" animations
		if last_direction == "right":
			sprite.play("run-right")
		else:
			sprite.play("run-left")
	else:
		# Playing "idle" animations based on the last direction moved
		if last_direction == "right":
			sprite.play("idle-right")
		else:
			sprite.play("idle-left")
