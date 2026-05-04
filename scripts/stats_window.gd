extends Control

signal closed

@onready var stats_list = $PanelContainer/StatsList

func _ready():
	# Ensure the window is hidden by default
	visible = false

func update_stats(player):
	# Clear existing rows except the title
	for child in stats_list.get_children():
		if child.name != "Title":
			child.queue_free()
	
	var wep = player.current_weapon
	
	# --- Weapon Stats ---
	if wep:
		add_stat_row("Damage", wep.base_damage, wep.damage)
		add_stat_row("Fire Rate", wep.base_fire_rate, wep.fire_rate, true) # Lower is better
		add_stat_row("Reload Speed", wep.base_reload_speed, wep.reload_speed, true) # Lower is better
		add_stat_row("Spread", wep.base_spread, wep.spread, true) # Lower is better
		add_stat_row("Crit Rate", wep.base_crit_rate, wep.crit_rate, false, true)
		add_stat_row("Crit Damage", wep.base_crit_damage, wep.crit_damage, false, true)
		
		# Flat stats (Current only)
		add_flat_row("Penetration", wep.penetration)
		add_flat_row("Projectiles", wep.projectiles)
		add_flat_row("Burst Count", wep.burst_count)
	else:
		add_flat_row("Weapon", "None")
	
	# --- Player Stats ---
	var current_speed = player.speed * (1.0 + player.speed_mod)
	add_stat_row("Move Speed", player.speed, current_speed)
	add_flat_row("Max HP", player.max_hp)
	add_flat_row("HP Regen", str(round(player.regen_rate * 100.0)) + "%/min")
	add_flat_row("XP Multiplier", player.xp_multiplier)

func add_stat_row(label_text: String, base_val: float, current_val: float, lower_is_better: bool = false, is_percentage: bool = false):
	var row = HBoxContainer.new()
	
	var name_label = Label.new()
	name_label.text = label_text
	name_label.custom_minimum_size.x = 150
	
	var base_str = str(base_val)
	var curr_str = str(current_val)
	
	if is_percentage:
		base_str = str(round(base_val * 100.0)) + "%"
		curr_str = str(round(current_val * 100.0)) + "%"
	
	var base_label = Label.new()
	base_label.text = base_str
	base_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	base_label.custom_minimum_size.x = 50
	
	var arrow = Label.new()
	arrow.text = " -> "
	
	var current_label = Label.new()
	current_label.text = curr_str
	current_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	current_label.custom_minimum_size.x = 50
	
	# Color Logic
	var is_better = false
	if lower_is_better:
		is_better = current_val < base_val
	else:
		is_better = current_val > base_val
		
	if is_better:
		current_label.modulate = Color(0, 1, 0) # Green
	elif current_val != base_val:
		current_label.modulate = Color(1, 0, 0) # Red
	
	row.add_child(name_label)
	row.add_child(base_label)
	row.add_child(arrow)
	row.add_child(current_label)
	
	stats_list.add_child(row)

func add_flat_row(label_text: String, value):
	var row = HBoxContainer.new()
	
	var name_label = Label.new()
	name_label.text = label_text
	name_label.custom_minimum_size.x = 150
	
	var val_label = Label.new()
	val_label.text = str(value)
	val_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	val_label.custom_minimum_size.x = 100
	
	row.add_child(name_label)
	row.add_child(val_label)
	
	stats_list.add_child(row)
