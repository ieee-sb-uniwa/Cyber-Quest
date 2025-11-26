extends Button

@export var key_value: String = ""
@export var key_display: String = ""
@export var key_type: String = "character"

var key_label: Label

signal key_pressed(key_value, key_type)

func _ready():
	key_label = get_node("KeyLabel")
	
	if key_display.is_empty():
		key_display = key_value
	
	if key_label != null:
		key_label.text = key_display
	else:
		print("KeyLabel not found!")
	
	pressed.connect(_on_pressed)

func _on_pressed():
	emit_signal("key_pressed", key_value, key_type)

func update_key(new_value: String, new_display: String = ""):
	key_value = new_value
	key_display = new_display if not new_display.is_empty() else new_value
	if key_label != null:
		key_label.text = key_display
