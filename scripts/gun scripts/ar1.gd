extends BaseWeapon

func _ready():
	fire_rate = 0.5
	damage = 22.0
	magazine_size = 30
	current_ammo = 30
	reload_speed = 2.0
	bullet_speed = 750.0
	penetration = 1
	spread = 0.05
	projectiles = 1
	burst_count = 3
	burst_delay = 0.08
	crit_rate = 0.1
	crit_damage = 1.5
	is_automatic = true
