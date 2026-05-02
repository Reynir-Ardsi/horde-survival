class_name BaseWeapon
extends Node2D

@export var bullet_scene: PackedScene = preload("res://scenes/player/bullet.tscn")

@export var fire_rate: float = 0.4
@export var damage: float = 20.0
@export var magazine_size: int = 10
@export var current_ammo: int = 10
@export var reload_speed: float = 1.5
@export var bullet_speed: float = 600.0
@export var penetration: int = 1
@export var spread: float = 0.0 # In radians
@export var crit_rate: float = 0.0 # 0.0 to 1.0
@export var crit_damage: float = 2.0
@export var burst_count: int = 1
@export var burst_delay: float = 0.1
@export var projectiles: int = 1
@export var is_automatic: bool = false

var owner_actor
var can_fire := true
var is_reloading: bool = false

@onready var muzzle: Marker2D = $Muzzle
@onready var sprite: Sprite2D = $Sprite2D

func initialize(owner):
	owner_actor = owner

func aim(target_pos: Vector2):
	var aim_dir = (target_pos - global_position).normalized()
	rotation = aim_dir.angle()

	if sprite:
		var angle = aim_dir.angle()
		if angle > PI/2 or angle < -PI/2:
			sprite.flip_v = true
		else:
			sprite.flip_v = false

func fire():
	if not can_fire or is_reloading:
		return
		
	if current_ammo <= 0:
		reload()
		return

	can_fire = false
	current_ammo -= 1

	for b in range(burst_count):
		for p in range(projectiles):
			spawn_bullet(damage)
			
		if burst_count > 1 and b < burst_count - 1:
			await get_tree().create_timer(burst_delay).timeout

	await get_tree().create_timer(fire_rate).timeout
	can_fire = true
	
	if current_ammo <= 0:
		reload()

func spawn_bullet(dmg: float = 0.0):
	if bullet_scene == null:
		return

	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)

	if muzzle:
		bullet.global_position = muzzle.global_position
	else:
		bullet.global_position = global_position

	var spread_offset = randf_range(-spread / 2.0, spread / 2.0)
	var final_rotation = rotation + spread_offset
	var dir = Vector2.RIGHT.rotated(final_rotation)
	
	if bullet.has_method("initialize"):
		bullet.initialize(dir, dmg, penetration, crit_rate, crit_damage, bullet_speed)

func reload():
	if is_reloading or current_ammo == magazine_size:
		return
	
	is_reloading = true
	await get_tree().create_timer(reload_speed).timeout
	
	current_ammo = magazine_size
	is_reloading = false
