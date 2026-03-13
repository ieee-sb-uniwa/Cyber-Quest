extends Control

@warning_ignore("integer_division")
@onready var lvl: Node2D = get_node("../../../") # Level_1_x
@onready var pause_interaction: Node2D = $"../pause_interaction"


func _on_resume_pressed():
	pause_interaction.pausemenu()


func _on_settings_pressed():
	# Hide pause menu instead of full unpause to keep the state
	self.hide()
	print("[PauseMenu] settings -> opening Options as overlay")
	
	var options_node = Controller._open_overlay_menu("Options_Menu")
	
	# Custom setup for Options when opened from Pause Menu
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
	# Hide pause menu instead of full unpause to keep the state
	self.hide()
	print("[PauseMenu] load -> opening Load Menu as overlay")
	
	var load_node = Controller._open_overlay_menu("Load_Menu")
	
	# Custom setup for Load Menu when opened from Pause Menu
	var BacktoMenu: Button = load_node.get_node("VBoxContainer2/BacktoMenu")
	var Return: Button = load_node.get_node("VBoxContainer2/ResumePlaying")
	BacktoMenu.hide()	# Switch the Quit and Resume Buttons
	Return.show()
	lvl.hide()	# Hide level
	$"../../InventoryGUI".hide()	# Hide Inv_slots
