extends CharacterBody2D

@export var speed := 80
@export var acceleration := 1200
@export var friction := 800

@export var ar1: PackedScene = preload("res://scenes/gun scenes/ar1.tscn")
@export var ar2: PackedScene = preload("res://scenes/gun scenes/ar2.tscn")
@export var smg1: PackedScene = preload("res://scenes/gun scenes/smg1.tscn")
@export var smg2: PackedScene = preload("res://scenes/gun scenes/smg2.tscn")
@export var lmg1: PackedScene = preload("res://scenes/gun scenes/lmg1.tscn")
@export var lmg2: PackedScene = preload("res://scenes/gun scenes/lmg2.tscn")
@export var shtgn1: PackedScene = preload("res://scenes/gun scenes/shtgn1.tscn")
@export var shtgn2: PackedScene = preload("res://scenes/gun scenes/shtgn2.tscn")
@export var snpr1: PackedScene = preload("res://scenes/gun scenes/snpr1.tscn")
@export var snpr2: PackedScene = preload("res://scenes/gun scenes/snpr2.tscn")
@export var pstl: PackedScene = preload("res://scenes/gun scenes/pstl.tscn")

@onready var sprite: AnimatedSprite2D = $Body
@onready var weapon_socket: Marker2D = $WeaponSocket

@export var max_hp: float = 100.0
var current_hp: float = 100.0

var level: int = 1
var current_xp: float = 0.0
var max_xp: float = 100.0

@onready var hp_bar: ProgressBar = $HUD/VBoxContainer/HPBar
@onready var xp_bar: ProgressBar = $HUD/XPBar
@onready var level_label: Label = $HUD/XPBar/LevelLabel

var current_weapon: Node2D
var input_dir = Vector2.ZERO
# Track the last direction the player moved (defaulting to right)
var last_direction = "right"

var reload_bar: ProgressBar

func _ready():
	add_to_group("player")
	current_hp = max_hp
	equip_weapon(shtgn2)
	
	reload_bar = ProgressBar.new()
	reload_bar.show_percentage = false
	reload_bar.custom_minimum_size = Vector2(100, 15)
	reload_bar.size = Vector2(100, 15)
	reload_bar.position = Vector2(-50, -60)
	reload_bar.visible = false
	reload_bar.modulate = Color(1.0, 0.8, 0.2) # Yellow/Orange
	add_child(reload_bar)
	
	update_ui()

func show_reload_bar():
	if reload_bar:
		reload_bar.visible = true
		reload_bar.value = 0

func hide_reload_bar():
	if reload_bar:
		reload_bar.visible = false

func update_reload_bar(progress: float):
	if reload_bar:
		reload_bar.value = progress * 100

func update_ui():
	if hp_bar:
		hp_bar.max_value = max_hp
		hp_bar.value = current_hp
	if xp_bar:
		xp_bar.max_value = max_xp
		xp_bar.value = current_xp
	if level_label:
		level_label.text = "Level: " + str(level)

func take_damage(amount: float):
	current_hp -= amount
	update_ui()
	if current_hp <= 0:
		die()

func die():
	get_tree().reload_current_scene()

func gain_xp(amount: float):
	current_xp += amount
	if current_xp >= max_xp:
		level_up()
	update_ui()

func level_up():
	level += 1
	current_xp -= max_xp
	max_xp *= 1.5
	
	# Handle multiple level-ups at once if gained a ton of XP
	if current_xp >= max_xp:
		level_up()

func _process(delta):
	if current_hp < max_hp:
		# 5% of max_hp per minute (divided by 60 seconds)
		current_hp += (max_hp * 0.05) * (delta / 60.0)
		if current_hp > max_hp:
			current_hp = max_hp
		update_ui()

func _physics_process(delta):
	handle_movement()
	handle_aim()
	handle_shooting()

func handle_shooting():
	if current_weapon == null:
		return
		
	var is_auto = false
	if "is_automatic" in current_weapon:
		is_auto = current_weapon.is_automatic
		
	if is_auto:
		if Input.is_action_pressed("shoot"):
			current_weapon.fire()
	else:
		if Input.is_action_just_pressed("shoot"):
			current_weapon.fire()

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
