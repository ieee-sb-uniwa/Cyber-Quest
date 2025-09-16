extends Node

func _ready():
	var pairs = [
		[$Button1, $Bridge1],
		[$Button2, $Bridge2]
	]
	for pair in pairs:
		var button = pair[0]
		var bridge = pair[1]
		button.button_pressed.connect(bridge._on_button_pressed)
		button.button_unpressed.connect(bridge._on_button_unpressed)
