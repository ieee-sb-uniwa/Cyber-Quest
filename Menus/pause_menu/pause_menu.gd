extends Control

@onready var pause_interaction: Node2D = $"../pause_interaction"


func _on_resume_pressed():
	pause_interaction.pausemenu()


func _on_settings_pressed():
	pause_interaction.pausemenu()
	get_tree().change_scene_to_file("res://Menus/main_menu/Options-Menu.tscn")



func _on_quit_pressed():
	pause_interaction.pausemenu()
	get_tree().change_scene_to_file("res://Menus/main_menu/Menu.tscn")


func _on_save_pressed() -> void:
	Global.saveData.save_game()


func _on_load_pressed() -> void:
	get_tree().change_scene_to_file("res://Menus/main_menu/Load-Menu.tscn");
