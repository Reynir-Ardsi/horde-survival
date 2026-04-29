extends Node2D

@export var bullet_scene: PackedScene = preload("res://scenes/player/bullet.tscn")
@export var fire_rate := 0.2

var owner_actor
var can_fire := true

@onready var muzzle: Marker2D = $Muzzle

func _process(delta: float) -> void:
	update_flip()

func initialize(owner):
	owner_actor = owner

func update_flip():
	var aim_dir = (get_global_mouse_position() - global_position).normalized()
	var angle = aim_dir.angle()

	if angle > PI/2 or angle < -PI/2:
		$Sprite2D.flip_v = true
	else:
		$Sprite2D.flip_v = false

func fire():
	if not can_fire:
		return

	can_fire = false

	spawn_bullet()

	await get_tree().create_timer(fire_rate).timeout
	can_fire = true

func spawn_bullet():
	if bullet_scene == null:
		return

	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)

	bullet.global_position = muzzle.global_position

	var dir = (get_global_mouse_position() - global_position).normalized()
	if bullet.has_method("initialize"):
		bullet.initialize(dir)
