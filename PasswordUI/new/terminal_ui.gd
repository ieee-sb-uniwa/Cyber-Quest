extends Control

@onready var display_text: RichTextLabel = $DisplayScreen/OutputText
@onready var keyboard_manager = $KeyboardContainer/KeyboardLayout
@onready var shift_toggle: Button = $KeyboardContainer/ShiftToggle
@onready var numpad_bg: Control = $KeyboardContainer/NumpadBackground
@onready var letters_bg: Control = $KeyboardContainer/LettersBackground
@onready var symbols_bg: Control = $KeyboardContainer/SymbolsBackground

var current_level: int = 3 # Hard coded for testing full terminal

func _ready():
	keyboard_manager.key_pressed.connect(_on_keyboard_key_pressed)
	shift_toggle.toggled.connect(_on_shift_toggled)
	setup_level(current_level)

func setup_level(level: int):
	current_level = level
	
	numpad_bg.visible = false
	letters_bg.visible = false
	symbols_bg.visible = false
	
	match level: #To be swapped with inventory slots
		1:
			keyboard_manager.setup_level_layouts(1)
			$KeyboardContainer/ShiftToggle.visible = false
			numpad_bg.visible = true
			
		2:
			keyboard_manager.setup_level_layouts(2)
			$KeyboardContainer/ShiftToggle.visible = true
			numpad_bg.visible = true
			letters_bg.visible = true
			
		3:
			keyboard_manager.setup_level_layouts(3)
			$KeyboardContainer/ShiftToggle.visible = true
			numpad_bg.visible = true
			letters_bg.visible = true
			symbols_bg.visible = true

func _on_keyboard_key_pressed(key_value: String, key_type: String):
	match key_type:
		"action":
			handle_action_key(key_value)
		"character", "number", "symbol":
			display_text.text += key_value

func handle_action_key(action: String):
	match action:
		"backspace":
			if display_text.text.length() > 0:
				display_text.text = display_text.text.substr(0, display_text.text.length() - 1)
		"enter":
			process_command(display_text.text)
			display_text.text = ""
		" ":
			display_text.text += " "

func _on_shift_toggled(button_pressed: bool):
	keyboard_manager.is_uppercase = button_pressed

func process_command(command: String):
	print("Command:", command)

func advance_to_next_level():
	current_level += 1
	if current_level <= 3:
		setup_level(current_level)
