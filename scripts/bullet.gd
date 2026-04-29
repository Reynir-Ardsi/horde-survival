extends Area2D

@export var speed := 600
var direction := Vector2.ZERO
var damage := 0.0

func initialize(dir: Vector2, dmg: float = 0.0):
	direction = dir.normalized()
	rotation = direction.angle()
	damage = dmg

func _process(delta):
	position += direction * speed * delta
