extends Control

@warning_ignore("integer_division")
@onready var lvl: Node2D = get_parent().get_parent().get_parent()	# Shitty way of finding Level parent node
@onready var pause_interaction: Node2D = $"../pause_interaction"
@onready var load_scene = preload("res://Menus/main_menu/Load-Menu.tscn")	
@onready var options_scene = preload("res://Menus/main_menu/Options-Menu.tscn")


func _on_resume_pressed():
	pause_interaction.pausemenu()


func _on_settings_pressed():
	
	# Try to unpause safely, then defer the scene change on this node.
	if pause_interaction and pause_interaction.has_method("pausemenu"):
		pause_interaction.pausemenu()
	# Ensure tree is unpaused before scene switch
	if get_tree().paused:
		get_tree().paused = false
	print("[PauseMenu] settings -> unpaused and switching to Options")
	var options_instance = options_scene.instantiate()	# Create Options Menu
	lvl.hide()	# Hide level
	get_parent().add_sibling(options_instance)	# Add the Options Menu as sibling
	var BacktoMenu: Button = $"../../Options Menu/VBoxContainer2/BacktoMenu"
	var Return: Button = $"../../Options Menu/VBoxContainer2/ResumePlaying"
	BacktoMenu.hide()	# Switch the Quit and Resume Buttons
	Return.show()
	$"../../InventoryGUI".hide() # Hide Inv_slots
	#get_tree().call_deferred("change_scene_to_file", "res://Menus/main_menu/Options-Menu.tscn") ## Unused

func _on_quit_pressed():
	# Safely unpause and go back to main menu
	if pause_interaction and pause_interaction.has_method("pausemenu"):
		pause_interaction.pausemenu()
	if get_tree().paused:
		get_tree().paused = false
	print("[PauseMenu] quit -> unpaused and switching to Main Menu")
	get_tree().call_deferred("change_scene_to_file", "res://Menus/main_menu/Menu.tscn")

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
	print("[PauseMenu] load -> unpaused and switching to Load Menu")
	get_tree().call_deferred("change_scene_to_file", "res://Menus/main_menu/Load-Menu.tscn")
	
func _on_restart_pressed(): 
	get_tree().change_scene_to_file("res://Menus/main_menu/Menu.tscn")
	pause_interaction.pausemenu()
	var load_instance = load_scene.instantiate()	# Create Load Menu
	lvl.hide()	# Hide level
	get_parent().add_sibling(load_instance)	# Add the Load Menu as sibling
	var BacktoMenu: Button = $"../../LoadMenu/VBoxContainer2/BacktoMenu"
	var Return: Button = $"../../LoadMenu/VBoxContainer2/ResumePlaying"
	BacktoMenu.hide()	# Switch the Quit and Resume Buttons
	Return.show()
	$"../../InventoryGUI".hide()	# Hide Inv_slots
	#get_tree().call_deferred("change_scene_to_file", "res://Menus/main_menu/Load-Menu.tscn") ## Unused
