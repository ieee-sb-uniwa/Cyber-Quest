extends Control

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
	print("[PauseMenu] settings -> unpaused and switching to Options")
	get_tree().call_deferred("change_scene_to_file", "res://Menus/main_menu/Options-Menu.tscn")



func _on_quit_pressed():
	# Safely unpause and go back to main menu
	if pause_interaction and pause_interaction.has_method("pausemenu"):
		pause_interaction.pausemenu()
	if get_tree().paused:
		get_tree().paused = false
	print("[PauseMenu] quit -> unpaused and switching to Main Menu")
	get_tree().call_deferred("change_scene_to_file", "res://Menus/main_menu/Menu.tscn")


func _on_save_pressed() -> void:
	Global.saveData.save_game()


func _on_load_pressed() -> void:
	# Safely unpause before opening the Load menu
	if pause_interaction and pause_interaction.has_method("pausemenu"):
		pause_interaction.pausemenu()
	if get_tree().paused:
		get_tree().paused = false
	print("[PauseMenu] load -> unpaused and switching to Load Menu")
	get_tree().call_deferred("change_scene_to_file", "res://Menus/main_menu/Load-Menu.tscn")
