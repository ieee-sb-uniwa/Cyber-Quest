extends Node2D
@onready var sprite = $Sprite2D
@onready var button_active = 0

signal button_pressed()
signal button_unpressed()

func _on_button_pressed(_body: Node2D) -> void:
	if button_active >= 1:
		button_active += 1
	else:
		sprite.frame = 15
		emit_signal("button_pressed")
		button_active += 1

func _on_button_unpressed(_body: Node2D) -> void:
	if button_active > 1:
		button_active -= 1
	else:
		sprite.frame = 14
		emit_signal("button_unpressed")
		button_active -= 1
