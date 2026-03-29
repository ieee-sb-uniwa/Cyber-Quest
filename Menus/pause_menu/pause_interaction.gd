extends Node2D

@onready var pause_menu: Control = $"../Pause_menu"
@onready var pause_button: Control = $"../Pause_button"

var paused = false 

func _process(_delta):
	if Input.is_action_just_pressed("Pause"):
		pausemenu()

func pausemenu():
	# When in any UI, disable pausing
	if !Global.can_pause_game:
		return
	if not is_inside_tree():
		return
	var tree := get_tree()
	if tree == null:
		return
	if paused: # Unpause
		pause_menu.hide()
		pause_button.show()
		tree.paused = false 
		paused = false
	else:
		pause_menu.show()
		pause_button.hide()
		tree.paused = true
		paused = true
