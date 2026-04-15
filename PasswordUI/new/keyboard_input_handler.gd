extends Node

class_name keyboard_input_handler

signal key_entered(key_value: String, key_type: String)
signal shift_pressed()

#caps lock and shift for the same button (keep the toggled state as caps_lock)
var caps_lock: bool = false
var shift_key_pressed: bool = false

# Mapping for shifted symbols (when shift key physically held down)
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
	if not event is InputEventKey:
		return
	
	# Physical shift key state
	if event.keycode == KEY_SHIFT:
		shift_key_pressed = event.pressed
		if event.pressed:
			caps_lock = !caps_lock
			shift_pressed.emit() 
			print("Physical shift toggled - Caps Lock: ", caps_lock)  # For debugging
		return
	
	# Process on key PRESS
	if not event.pressed:
		return

	# Toggle Caps Lock when pressed
	if event.keycode == KEY_CAPSLOCK:
		caps_lock = !caps_lock
		print("Caps Lock pressed - Caps Lock: ", caps_lock)  # For debugging
		return

	match event.keycode:
		KEY_ENTER, KEY_KP_ENTER:
			key_entered.emit("✔", "action")
		KEY_BACKSPACE:
			key_entered.emit("X", "action")
		KEY_ESCAPE:
			key_entered.emit("Cancel", "action")
		KEY_SPACE:
			key_entered.emit(" ", "space")
		_:
			var character = _get_character_from_event(event)
			if character != "":
				key_entered.emit(character, "key")

func _get_character_from_event(event: InputEventKey) -> String:
	# For letters: Caps Lock toggles upper/lowercase
	if event.keycode >= KEY_A and event.keycode <= KEY_Z:
		var letter = char(event.keycode)
		return letter.to_upper() if caps_lock else letter.to_lower()

	# For symbols: Shift produces symbols while held down
	if event.keycode >= KEY_0 and event.keycode <= KEY_9:
		if shift_key_pressed:
			return SHIFTED_SYMBOLS.get(event.keycode, "")
		return char(event.keycode)

	# For numpads: Never affected by shift
	if event.keycode >= KEY_KP_0 and event.keycode <= KEY_KP_9:
		return str(event.keycode - KEY_KP_0)

	# Numpad operators
	match event.keycode:
		KEY_KP_ADD:      return "+"
		KEY_KP_SUBTRACT: return "-"
		KEY_KP_MULTIPLY: return "*"
		KEY_KP_DIVIDE:   return "/"
		KEY_KP_PERIOD:   return "."

	# For symbols: Shift produces symbols while held down
	if shift_key_pressed:
		return SHIFTED_SYMBOLS.get(event.keycode, "")
	
	match event.keycode:
		KEY_MINUS:       return "-"
		KEY_EQUAL:       return "="
		KEY_BRACKETLEFT: return "["
		KEY_BRACKETRIGHT: return "]"
		KEY_SEMICOLON:   return ";"
		KEY_APOSTROPHE:  return "'"
		KEY_COMMA:       return ","
		KEY_PERIOD:      return "."
		KEY_SLASH:       return "/"
		KEY_BACKSLASH:   return "\\"

	return ""

# On-screen shift button to check current state
func is_shift_active() -> bool:
	return caps_lock

# Toggle (called by on-screen shift button)
func toggle_caps_lock():
	caps_lock = !caps_lock
	print("On-screen shift toggled - Caps Lock: ", caps_lock)  # Debug line

# Reset when terminal closes
func reset_modifiers():
	caps_lock = false
	shift_key_pressed = false
