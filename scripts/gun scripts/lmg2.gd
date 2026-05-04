extends BaseWeapon

func _ready():
	fire_rate = 0.05
	damage = 18.0
	magazine_size = 150
	current_ammo = 150
	reload_speed = 5.0
	bullet_speed = 680.0
	penetration = 1
	spread = 0.15
	projectiles = 1
	burst_count = 1
	burst_delay = 0
	crit_rate = 0.1
	crit_damage = 1.5
	is_automatic = true
