extends BaseWeapon

func _init():
	fire_rate = 0.09
	damage = 20.0
	magazine_size = 200
	current_ammo = 100
	reload_speed = 10.0
	bullet_speed = 650.0
	penetration = 1
	spread = 0.2
	projectiles = 1
	burst_count = 1
	burst_delay = 0
	crit_rate = 0.1
	crit_damage = 1.5
	is_automatic = true
