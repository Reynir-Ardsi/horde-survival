extends CharacterBody2D

enum State { CHASE, ATTACK, DEAD }
var speed := 30.0
var current_state = State.CHASE
var player: Node2D = null

var hp := 100.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	add_to_group("enemies")
	speed = randf_range(speed * 0.8, speed * 1.2)
	player = get_tree().get_first_node_in_group("player")
	sprite.animation_finished.connect(_on_animation_finished)

func _physics_process(_delta: float) -> void:
	if current_state == State.DEAD:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if not player:
		player = get_tree().get_first_node_in_group("player")
		if not player:
			return

	match current_state:
		State.CHASE:
			handle_chase()
		State.ATTACK:
			handle_attack()

func handle_chase() -> void:
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * speed

	update_animation(direction)
	move_and_slide()

func handle_attack() -> void:
	velocity = Vector2.ZERO
	if sprite.sprite_frames.has_animation("attack"):
		sprite.play("attack")
	elif sprite.sprite_frames.has_animation("attack1"):
		sprite.play("attack1")
	elif sprite.sprite_frames.has_animation("attack2"):
		sprite.play("attack2")
	move_and_slide()

func update_animation(dir: Vector2) -> void:
	if dir.length() < 0.1:
		return

	if sprite.sprite_frames.has_animation("walk"):
		sprite.play("walk")
	elif sprite.sprite_frames.has_animation("walk1"):
		sprite.play("walk1")

	if dir.x < 0:
		sprite.flip_h = true
	elif dir.x > 0:
		sprite.flip_h = false

func take_damage(amount: float) -> void:
	if current_state == State.DEAD:
		return
	hp -= amount
	if hp <= 0:
		die()

func die() -> void:
	if current_state == State.DEAD:
		return
	current_state = State.DEAD

	if has_node("Hitbox/CollisionShape2D"):
		$Hitbox/CollisionShape2D.set_deferred("disabled", true)
	$CollisionShape.set_deferred("disabled", true)
	sprite.play("die1")

func _on_animation_finished() -> void:
	if current_state == State.DEAD:
		queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if current_state == State.DEAD:
		return
	if body.is_in_group("player"):
		current_state = State.ATTACK

func _on_area_2d_body_exited(body: Node2D) -> void:
	if current_state == State.DEAD:
		return
	if body.is_in_group("player"):
		current_state = State.CHASE

func _on_hitbox_area_entered(area: Area2D) -> void:
	if current_state == State.DEAD:
		return
	if area.is_in_group("bullet"):
		take_damage(area.damage)
		if area.has_method("handle_hit"):
			area.handle_hit()
		else:
			area.queue_free()
