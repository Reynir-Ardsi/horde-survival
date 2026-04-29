extends Area2D

@export var speed := 1000
var direction := Vector2.ZERO

func initialize(dir: Vector2):
	direction = dir.normalized()
	rotation = direction.angle()

func _process(delta):
	position += direction * speed * delta


func _on_body_entered(body):
	queue_free()
