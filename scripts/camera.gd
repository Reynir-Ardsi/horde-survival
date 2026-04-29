extends Camera2D

@export var max_lookahead := 80.0
@export var smoothing := 5.0

func _process(delta):
	var mouse_world = get_global_mouse_position()
	var dir = mouse_world - get_parent().global_position

	var desired_offset = dir * 0.5
	
	if desired_offset.length() > max_lookahead:
		desired_offset = desired_offset.normalized() * max_lookahead

	offset = offset.lerp(
		desired_offset,
		smoothing * delta
	)
