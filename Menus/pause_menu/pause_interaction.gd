extends Node2D

@onready var pause_menu: Control = $"../PauseMenu/Pause_menu"
@onready var pause_button: Control = $"../PauseMenu/Pause_button"

var paused = false 

func _process(delta):
	if Input.is_action_just_pressed("Pause"):
		pausemenu()

func pausemenu():
	if paused:
		pause_menu.hide()
		pause_button.show()
		get_tree().paused = false 
		paused = false
	else:
		pause_menu.show()
		pause_button.hide()
		get_tree().paused = true
		paused = true
