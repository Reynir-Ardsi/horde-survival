extends BaseWeapon

@export var fire_rate := 0.4
@export var damage := 20.0

func fire():
	if not can_fire:
		return

	can_fire = false
	spawn_bullet(damage)

	await get_tree().create_timer(fire_rate).timeout
	can_fire = true
