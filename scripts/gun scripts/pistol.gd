extends BaseWeapon

@export var fire_rate := 0.4

func fire():
	if not can_fire:
		return

	can_fire = false
	spawn_bullet()

	await get_tree().create_timer(fire_rate).timeout
	can_fire = true
