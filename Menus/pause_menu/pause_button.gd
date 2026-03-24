extends Control

@onready var pause_interaction: Node2D = $"../pause_interaction"

func _on_pause_pressed():
	print(get_tree_string_pretty())
	pause_interaction.pausemenu()
