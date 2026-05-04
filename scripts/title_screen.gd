extends Control

signal start_game

@onready var play_button: Button = $Button
var click_sound: AudioStreamPlayer
var click_timer: Timer

func _ready():
	click_sound = AudioStreamPlayer.new()
	click_sound.stream = load("res://assets/audio/button_click.mp3")
	click_sound.volume_db = -5.0
	add_child(click_sound)

	click_timer = Timer.new()
	click_timer.wait_time = 0.13
	click_timer.one_shot = true
	click_timer.timeout.connect(_on_click_timer_timeout)
	add_child(click_timer)

	play_button.pressed.connect(_on_play_button_pressed)

func _on_play_button_pressed():
	click_sound.play()
	click_sound.seek(0.23)
	click_timer.start()
	start_game.emit()

func _on_click_timer_timeout():
	click_sound.stop()
