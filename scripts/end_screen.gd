extends Control

signal restart_game

@onready var restart_button: Button = $Restart
@onready var score_label: Label = $"High Score"

func _ready():
	restart_button.pressed.connect(_on_restart_button_pressed)

func _on_restart_button_pressed():
	restart_game.emit()

func set_score(time_str: String):
	if score_label:
		score_label.text = "Time Survived: " + time_str