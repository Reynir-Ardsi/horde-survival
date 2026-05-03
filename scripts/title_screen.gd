extends Control

@onready var play_button: Button = $Button

func _ready():
	play_button.pressed.connect(_on_play_button_pressed)

func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main.tscn")
