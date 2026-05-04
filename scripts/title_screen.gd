extends Control

signal start_game

@onready var play_button: Button = $Button

func _ready():
	play_button.pressed.connect(_on_play_button_pressed)

func _on_play_button_pressed():
	start_game.emit()
