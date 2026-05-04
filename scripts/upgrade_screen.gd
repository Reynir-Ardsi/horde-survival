extends Control

signal upgrade_selected

@onready var btn1 = $Button3
@onready var btn2 = $Button2
@onready var btn3 = $Button
@onready var reroll_btn = $Button4

var current_level: int = 0
var rerolls_left: int = 2
var player: CharacterBody2D
var choices = []

# Dictionaries holding our upgrades
var player_upgrades = [
	{"text": "+20 Max HP", "type": "player", "stat": "max_hp", "val": 20.0},
	{"text": "+10% Speed", "type": "player", "stat": "speed_mod", "val": 0.1},
	{"text": "+20% XP Gain", "type": "player", "stat": "xp_multiplier", "val": 0.2},
	{"text": "+2% Health Regen", "type": "player", "stat": "regen_rate", "val": 0.02}
]

var gun_upgrades = [
	{"text": "+15% Damage", "type": "gun", "stat": "damage_mod", "val": 0.15},
	{"text": "-10% Fire Rate", "type": "gun", "stat": "fire_rate_mod", "val": -0.1},
	{"text": "+5 Mag Size", "type": "gun", "stat": "magazine_size", "val": 5},
	{"text": "-15% Reload Speed", "type": "gun", "stat": "reload_speed_mod", "val": -0.15},
	{"text": "+1 Penetration", "type": "gun", "stat": "penetration", "val": 1},
	{"text": "-15% Spread", "type": "gun", "stat": "spread_mod", "val": -0.15},
	{"text": "+5% Crit Rate", "type": "gun", "stat": "crit_rate", "val": 0.05},
	{"text": "+50% Crit Damage", "type": "gun", "stat": "crit_damage", "val": 0.5},
	{"text": "+1 Projectile (+Spread)", "type": "gun", "stat": "projectiles", "val": 1},
	{"text": "+1 Burst Count", "type": "gun", "stat": "burst_count", "val": 1}
]

var weapons = []
var can_click := false

func _ready():
	btn1.pressed.connect(func(): _on_choice_selected(0))
	btn2.pressed.connect(func(): _on_choice_selected(1))
	btn3.pressed.connect(func(): _on_choice_selected(2))
	reroll_btn.pressed.connect(_on_reroll_pressed)
	process_mode = Node.PROCESS_MODE_ALWAYS # Run even when game is paused

func open_screen(pl, lvl):
	player = pl
	current_level = lvl
	rerolls_left = 2
	
	can_click = false
	update_button_disabled_states()
	
	if weapons.is_empty():
		weapons = [
			{"text": "P90", "type": "weapon", "scene": player.ar1},
			{"text": "M4A1", "type": "weapon", "scene": player.ar2},
			{"text": "MP5K", "type": "weapon", "scene": player.smg1},
			{"text": "Uzi", "type": "weapon", "scene": player.smg2},
			{"text": "M249 SAW", "type": "weapon", "scene": player.lmg1},
			{"text": "Tommy Gun", "type": "weapon", "scene": player.lmg2},
			{"text": "Pump Action Shotgun", "type": "weapon", "scene": player.shtgn1},
			{"text": "Double Barrel Shotgun", "type": "weapon", "scene": player.shtgn2},
			{"text": "XM110", "type": "weapon", "scene": player.snpr1},
			{"text": "Barret M82", "type": "weapon", "scene": player.snpr2}
		]
		
	generate_choices()
	show()
	
	# Wait 2 seconds before allowing clicks to prevent misclicks
	get_tree().create_timer(2.0, true).timeout.connect(_on_timeout_finished)

func _on_timeout_finished():
	can_click = true
	update_button_disabled_states()

func update_button_disabled_states():
	if not can_click:
		btn1.disabled = true
		btn2.disabled = true
		btn3.disabled = true
		reroll_btn.disabled = true
	else:
		btn1.disabled = false
		btn2.disabled = false
		btn3.disabled = false
		reroll_btn.disabled = rerolls_left <= 0

func generate_choices():
	update_button_disabled_states()
	reroll_btn.text = "Reroll (" + str(rerolls_left) + ")"
	
	var pool = []
	if current_level < 3:
		pool = player_upgrades.duplicate()
	elif current_level == 3:
		pool = weapons.duplicate()
	else:
		pool = player_upgrades.duplicate()
		pool.append_array(gun_upgrades.duplicate())
		
	pool.shuffle()
	choices = []
	for i in range(min(3, pool.size())):
		choices.append(pool[i])
		
	btn1.text = choices[0].text if choices.size() > 0 else ""
	btn2.text = choices[1].text if choices.size() > 1 else ""
	btn3.text = choices[2].text if choices.size() > 2 else ""

func _on_reroll_pressed():
	if not can_click: return
	if rerolls_left > 0:
		rerolls_left -= 1
		generate_choices()

func _on_choice_selected(index: int):
	if not can_click: return
	if index >= choices.size(): return
	
	var choice = choices[index]
	if choice.type == "player":
		player.set(choice.stat, player.get(choice.stat) + choice.val)
		if choice.stat == "max_hp":
			player.current_hp += choice.val # Heal the extra HP
		player.update_ui()
	elif choice.type == "gun":
		var wep = player.current_weapon
		
		# Handle global player mods
		if choice.stat in ["damage_mod", "fire_rate_mod", "reload_speed_mod", "spread_mod"]:
			player.set(choice.stat, player.get(choice.stat) + choice.val)
			if wep.has_method("apply_modifiers"):
				wep.apply_modifiers(player)
		# Handle weapon-specific flat upgrades
		elif choice.stat == "projectiles":
			wep.projectiles += 1
			player.spread_mod += 0.05 # Drawback applied to global mod
			if wep.has_method("apply_modifiers"):
				wep.apply_modifiers(player)
		elif choice.stat == "burst_count":
			if wep.burst_count < 3:
				wep.burst_count = 3
			else:
				wep.burst_count += 1
		else:
			wep.set(choice.stat, wep.get(choice.stat) + choice.val)
			
	elif choice.type == "weapon":
		player.equip_weapon(choice.scene)
		
	upgrade_selected.emit()
