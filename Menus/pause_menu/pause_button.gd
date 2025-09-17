extends Control

@onready var pause_interaction: Node2D = $"../../pause_interaction"

func _on_pause_pressed():
	pause_interaction.pausemenu()
