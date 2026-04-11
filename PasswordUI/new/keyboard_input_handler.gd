extends Node

class_name keyboard_input_handler

signal key_entered(key_value: String, key_type: String)

# Track modifier states
var shift_pressed: bool = false
var caps_lock: bool = false

# Mapping for shifted symbols
const SHIFTED_SYMBOLS = {
	KEY_1: "!",
	KEY_2: "@",
	KEY_3: "#",
	KEY_4: "$",
	KEY_5: "%",
	KEY_6: "^",
	KEY_7: "&",
	KEY_8: "*",
	KEY_9: "(",
	KEY_0: ")",
	KEY_MINUS: "_",
	KEY_EQUAL: "+",
	KEY_BRACKETLEFT: "{",
	KEY_BRACKETRIGHT: "}",
	KEY_SEMICOLON: ":",
	KEY_APOSTROPHE: '"',
	KEY_COMMA: "<",
	KEY_PERIOD: ">",
	KEY_SLASH: "?",
	KEY_BACKSLASH: "|",
}

func _input(event):
	if not get_parent().is_visible_in_tree():
		return
	if get_parent().hasNum:
		return
	if event is InputEventKey and event.pressed:
		# Track shift key state
		if event.keycode == KEY_SHIFT:
			shift_pressed = event.pressed
			return
		
		# Track caps lock toggle
		if event.keycode == KEY_CAPSLOCK and event.pressed:
			caps_lock = !caps_lock
			return
		
		# Handle special keys
		match event.keycode:
			KEY_ENTER, KEY_KP_ENTER:
				key_entered.emit("✔", "action")
				return
			KEY_BACKSPACE:
				key_entered.emit("X", "action")
				return
			KEY_ESCAPE:
				key_entered.emit("Cancel", "action")
				return
			KEY_SPACE:
				key_entered.emit(" ", "space")
				return
		
		# Handle regular keys
		var character = _get_character_from_event(event)
		if character != "":
			key_entered.emit(character, "key")

func _get_character_from_event(event: InputEventKey) -> String:
	var character = ""
	
	# Check for letters
	if event.keycode >= KEY_A and event.keycode <= KEY_Z:
		var letter = char(event.keycode)
		if shift_pressed or caps_lock:
			character = letter.to_upper()
		else:
			character = letter.to_lower()
		return character
	
	# Check for numbers
	if event.keycode >= KEY_0 and event.keycode <= KEY_9:
		if shift_pressed:
			# Shifted number keys become symbols
			character = SHIFTED_SYMBOLS.get(event.keycode, "")
		else:
			character = char(event.keycode)
		return character
	
	# Check numpad numbers
	if event.keycode >= KEY_KP_0 and event.keycode <= KEY_KP_9:
		var num = event.keycode - KEY_KP_0
		character = str(num)
		return character
	
	# Check numpad operators
	match event.keycode:
		KEY_KP_ADD:
			character = "+"
		KEY_KP_SUBTRACT:
			character = "-"
		KEY_KP_MULTIPLY:
			character = "*"
		KEY_KP_DIVIDE:
			character = "/"
		KEY_KP_PERIOD:
			character = "."
	
	# Check special symbols
	if character == "":
		if shift_pressed:
			character = SHIFTED_SYMBOLS.get(event.keycode, "")
		else:
			# Handle regular symbols
			match event.keycode:
				KEY_MINUS:
					character = "-"
				KEY_EQUAL:
					character = "="
				KEY_BRACKETLEFT:
					character = "["
				KEY_BRACKETRIGHT:
					character = "]"
				KEY_SEMICOLON:
					character = ";"
				KEY_APOSTROPHE:
					character = "'"
				KEY_COMMA:
					character = ","
				KEY_PERIOD:
					character = "."
				KEY_SLASH:
					character = "/"
				KEY_BACKSLASH:
					character = "\\"
	
	return character

# Helper function to get current shift state
func is_shift_active() -> bool:
	return shift_pressed or caps_lock

# Reset modifier states (useful when terminal closes)
func reset_modifiers():
	shift_pressed = false
	caps_lock = false
