class_name BaseWeapon
extends Node2D

@export var bullet_scene: PackedScene = preload("res://scenes/player/bullet.tscn")

var owner_actor
var can_fire := true

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
	pass

func spawn_bullet():
	if bullet_scene == null:
		return

	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)

	if muzzle:
		bullet.global_position = muzzle.global_position
	else:
		bullet.global_position = global_position

	var dir = Vector2.RIGHT.rotated(rotation)
	if bullet.has_method("initialize"):
		bullet.initialize(dir)
