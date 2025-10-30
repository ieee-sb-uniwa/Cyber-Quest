extends Control

@onready var pause_interaction: Node2D = $"../pause_interaction"


func _on_resume_pressed():
	pause_interaction.pausemenu()


func _on_settings_pressed():
	pass 


func _on_restart_pressed(): 
	get_tree().change_scene_to_file("res://Menus/main_menu/Menu.tscn")
