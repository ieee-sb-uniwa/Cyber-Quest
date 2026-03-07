extends Control

@warning_ignore("integer_division")
@onready var lvl: Node2D = get_parent().get_parent().get_parent()	# Shitty way of finding Level parent node
@onready var pause_interaction: Node2D = $"../pause_interaction"


func _on_resume_pressed():
	pause_interaction.pausemenu()


func _on_settings_pressed():
	# Try to unpause safely, then defer the scene change on this node.
	if pause_interaction and pause_interaction.has_method("pausemenu"):
		pause_interaction.pausemenu()
	# Ensure tree is unpaused before scene switch
	if get_tree().paused:
		get_tree().paused = false
	print("[PauseMenu] settings -> switching to Options")
	
	Controller._open_menu_scene("Options_Menu")
	
	# Custom setup for Options when opened from Pause Menu
	var options_node = Controller.current_scene
	var BacktoMenu: Button = options_node.get_node("VBoxContainer2/BacktoMenu")
	var Return: Button = options_node.get_node("VBoxContainer2/ResumePlaying")
	BacktoMenu.hide()	# Switch the Quit and Resume Buttons
	Return.show()
	lvl.hide()	# Hide level
	$"../../InventoryGUI".hide() # Hide Inv_slots

func _on_quit_pressed():
	# Safely unpause and go back to main menu
	if pause_interaction and pause_interaction.has_method("pausemenu"):
		pause_interaction.pausemenu()
	if get_tree().paused:
		get_tree().paused = false
	print("[PauseMenu] quit -> unpaused and switching to Main Menu")
	Controller._open_menu_scene("Main_Menu")

# THIS WILL MAYBE USED FOR MULTI-SLOT SAVING IN THE FUTURE
func _on_save_pressed() -> void:
	pass
	# Global.saveData.save_game()

func _on_load_pressed() -> void:
	# Safely unpause before opening the Load menu
	if pause_interaction and pause_interaction.has_method("pausemenu"):
		pause_interaction.pausemenu()
	if get_tree().paused:
		get_tree().paused = false
	print("[PauseMenu] load -> switching to Load Menu")
	
	Controller._open_menu_scene("Load_Menu")
	
	# Custom setup for Load Menu when opened from Pause Menu
	var load_node = Controller.current_scene
	var BacktoMenu: Button = load_node.get_node("VBoxContainer2/BacktoMenu")
	var Return: Button = load_node.get_node("VBoxContainer2/ResumePlaying")
	BacktoMenu.hide()	# Switch the Quit and Resume Buttons
	Return.show()
	lvl.hide()	# Hide level
	$"../../InventoryGUI".hide()	# Hide Inv_slots
