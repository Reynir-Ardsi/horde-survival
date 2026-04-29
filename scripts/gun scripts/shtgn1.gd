extends BaseWeapon

@export var fire_rate := 3.0

@export var pellet_count := 8
@export var spread_angle := 0.4 # About 23 degrees

func fire():
	if not can_fire:
		return

	can_fire = false
	
	for i in range(pellet_count):
		spawn_shotgun_pellet()

	await get_tree().create_timer(fire_rate).timeout
	can_fire = true

func spawn_shotgun_pellet():
	if bullet_scene == null:
		return

	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)

	if muzzle:
		bullet.global_position = muzzle.global_position
	else:
		bullet.global_position = global_position

	# Calculate spread
	var random_spread = randf_range(-spread_angle / 2.0, spread_angle / 2.0)
	var dir = Vector2.RIGHT.rotated(rotation + random_spread)
	
	if bullet.has_method("initialize"):
		bullet.initialize(dir)
