extends CharacterBody2D

@export var speed := 250
@export var acceleration := 1200
@export var friction := 800
@onready var sprite: AnimatedSprite2D = $Body
@onready var weapon: Node2D = $Weapon
@onready var weapon_sprite: AnimatedSprite2D = $Weapon/WeaponSprite


var input_dir = Vector2.ZERO
var base_offset := Vector2(0, 0)

func _ready():
	add_to_group("player")

func _physics_process(delta):
	velocity = velocity.move_toward(input_dir * speed, acceleration * delta)
	velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	handle_movement()
	handle_aim()
	print("x: ", input_dir.x, "y: ", input_dir.y)
	update_sprite(input_dir)

func handle_movement():
	input_dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_dir.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	
	input_dir = input_dir.normalized()
	
	velocity = input_dir * speed
	move_and_slide()

func handle_aim():
	var mouse_pos = get_global_mouse_position()
	var dir = mouse_pos - global_position
	
	weapon.rotation = dir.angle()
	
	if dir.x < 0:
		weapon_sprite.flip_v = true
		weapon.position = Vector2(-base_offset.x, base_offset.y)
	else:
		weapon_sprite.flip_v = false
		weapon.position = base_offset
	
func _input(event):
	if event.is_action_pressed("shoot"):
		shoot()
		
func play_idle():
	weapon_sprite.play("fists-idle")

func update_sprite(input_dir):
	if input_dir.x > 0:
		sprite.play("run-right")
	elif input_dir.x < 0:
		sprite.play("run-left")
	elif input_dir.y > 0:
		sprite.play("run-down")
	elif input_dir.y < 0:
		sprite.play("run-up")
	else:
		sprite.play("idle")
	
		
func shoot():
	#var bullet = bullet.instantiate()
	#get_tree().current_scene.add_child(bullet)
	
	#bullet.global_position = global_position
	
	var direction = (get_global_mouse_position() - global_position).normalized()
	#bullet.initialize(direction)
