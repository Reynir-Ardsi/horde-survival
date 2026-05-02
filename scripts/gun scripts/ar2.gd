extends BaseWeapon

func _init():
	fire_rate = 0.15
	damage = 25.0
	magazine_size = 30
	current_ammo = 30
	reload_speed = 1.8
	bullet_speed = 700.0
	penetration = 1
	spread = 0.1
	projectiles = 1
	burst_count = 1
	burst_delay = 0
	crit_rate = 0.1
	crit_damage = 1.5
	is_automatic = true
