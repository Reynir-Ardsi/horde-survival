extends CharacterBody2D

signal leveled_up(new_level: int)

@export var speed := 60
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

@export var xp_multiplier: float = 1.0
@export var regen_rate: float = 0.05

var level: int = 0
var current_xp: float = 0.0
var max_xp: float = 100.0

@onready var hp_bar: ProgressBar = $HUD/VBoxContainer/HPBar
@onready var xp_bar: ProgressBar = $HUD/XPBar
@onready var level_label: Label = $HUD/XPBar/LevelLabel

# Percentage modifiers (0.1 = +10%)
var speed_mod: float = 0.0
var damage_mod: float = 0.0
var fire_rate_mod: float = 0.0 # Negative is faster
var reload_speed_mod: float = 0.0 # Negative is faster
var spread_mod: float = 0.0 # Negative is less spread

var current_weapon: Node2D
var input_dir = Vector2.ZERO
# Track the last direction the player moved (defaulting to right)
var last_direction = "right"

var reload_bar: ProgressBar

var is_active := false

func _ready():
	add_to_group("player")
	current_hp = max_hp
	equip_weapon(pstl)
	
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
	if get_parent().has_method("game_over"):
		get_parent().game_over()

func gain_xp(amount: float):
	current_xp += amount * xp_multiplier
	if current_xp >= max_xp:
		level_up()
	update_ui()

func level_up():
	level += 1
	current_xp -= max_xp
	max_xp *= 1.5
	
	leveled_up.emit(level)
	
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
	if current_weapon == null or not is_active:
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

	velocity = input_dir * (speed * (1.0 + speed_mod))
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
		if current_weapon and is_active:
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

func hide_hud():
	if has_node("HUD"):
		$HUD.visible = false

func show_hud():
	if has_node("HUD"):
		$HUD.visible = true

func reset():
	current_hp = max_hp
	level = 0
	current_xp = 0.0
	max_xp = 100.0
	xp_multiplier = 1.0
	regen_rate = 0.05
	speed = 80
	
	# Reset modifiers
	speed_mod = 0.0
	damage_mod = 0.0
	fire_rate_mod = 0.0
	reload_speed_mod = 0.0
	spread_mod = 0.0
	
	global_position = Vector2(504, 227) # Default starting position
	last_direction = "right"
	equip_weapon(pstl) # Reset to pistol
	update_ui()
