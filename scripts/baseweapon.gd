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
var reload_timer: float = 0.0

var base_fire_rate: float
var base_damage: float
var base_reload_speed: float
var base_spread: float
var base_crit_rate: float
var base_crit_damage: float

@onready var muzzle: Marker2D = $Muzzle
@onready var sprite: Sprite2D = $Sprite2D

func initialize(owner):
	owner_actor = owner
	setup_stats()
	
	base_fire_rate = fire_rate
	base_damage = damage
	base_reload_speed = reload_speed
	base_spread = spread
	base_crit_rate = crit_rate
	base_crit_damage = crit_damage
	
	if owner_actor:
		apply_modifiers(owner_actor)

func setup_stats():
	pass # Overridden by specific weapon scripts

func apply_modifiers(pl):
	# Base calculation
	damage = base_damage * (1.0 + pl.damage_mod)
	fire_rate = max(base_fire_rate * (1.0 + pl.fire_rate_mod), base_fire_rate * 0.2)
	reload_speed = max(base_reload_speed * (1.0 + pl.reload_speed_mod), base_reload_speed * 0.2)
	
	# Spread Calculation: Fix 0-spread bug by adding a flat penalty if spread_mod is positive
	var spread_penalty = 0.0
	if pl.spread_mod > 0:
		spread_penalty = pl.spread_mod * 0.1
	spread = max(base_spread * (1.0 + pl.spread_mod) + spread_penalty, 0.0)
	
	# Projectile Penalty: -15% damage for each projectile beyond the first
	if projectiles > 1:
		var penalty = 1.0 - ((projectiles - 1) * 0.15)
		damage *= max(penalty, 0.3) # Clamp to 30% minimum damage
	
	# Burst Penalty: +0.1s fire rate delay for each burst round beyond the first
	if burst_count > 1:
		fire_rate += (burst_count - 1) * 0.1
	
	# Absolute floors for sanity
	if fire_rate < 0.005: fire_rate = 0.005
	if reload_speed < 0.2: reload_speed = 0.2

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
			# Use a timer that respects pause if we want it to stop, 
			# but here we use the default which is pausable.
			await get_tree().create_timer(burst_delay).timeout

	if current_ammo <= 0:
		can_fire = true
		reload()
	else:
		await get_tree().create_timer(fire_rate).timeout
		can_fire = true

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

func _process(delta):
	if is_reloading:
		reload_timer -= delta
		if owner_actor and owner_actor.has_method("update_reload_bar"):
			owner_actor.update_reload_bar(1.0 - (reload_timer / reload_speed))
			
		if reload_timer <= 0:
			current_ammo = magazine_size
			is_reloading = false
			if owner_actor and owner_actor.has_method("hide_reload_bar"):
				owner_actor.hide_reload_bar()

func reload():
	if is_reloading or current_ammo == magazine_size:
		return
	
	is_reloading = true
	reload_timer = reload_speed
	if owner_actor and owner_actor.has_method("show_reload_bar"):
		owner_actor.show_reload_bar()
