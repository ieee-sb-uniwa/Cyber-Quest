extends Button

@export var key_value: String = ""
@export var key_display: String = ""
@export var key_type: String = "character"

signal key_pressed(key_value, key_type)

func _ready():
	call_deferred("deferred_setup")

func deferred_setup():
	await get_tree().process_frame
	
	setup_label()
	pressed.connect(_on_pressed)

func setup_label():
	var label = null
	for child in get_children():
		if child is Label:
			label = child
			break
	
	if label == null:
		label = Label.new()
		add_child(label)

	label.text = key_display

	await get_tree().process_frame

	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	label.add_theme_font_size_override("font_size", 20)
	
func _on_pressed():
	emit_signal("key_pressed", key_value, key_type)
