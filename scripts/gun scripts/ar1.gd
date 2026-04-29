extends BaseWeapon

@export var fire_rate := 0.8

# AR1 specific behavior: Burst fire
@export var burst_count := 3
@export var burst_delay := 0.05

func fire():
	if not can_fire:
		return

	can_fire = false
	
	for i in range(burst_count):
		spawn_bullet()
		if i < burst_count - 1:
			await get_tree().create_timer(burst_delay).timeout
			
	await get_tree().create_timer(fire_rate).timeout
	can_fire = true
