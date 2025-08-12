extends Node2D
@onready var sprite = $Sprite2D

signal button_pressed()
signal button_unpressed()

func _on_button_pressed(body: Node2D) -> void:
	sprite.frame = 15
	emit_signal("button_pressed")

func _on_button_unpressed(body: Node2D) -> void:
	sprite.frame = 14
	emit_signal("button_unpressed")
