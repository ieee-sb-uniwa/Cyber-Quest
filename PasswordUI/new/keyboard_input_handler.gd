extends Node

class_name keyboard_input_handler

signal key_entered(key_value: String, key_type: String)

# Track caps lock (Godot doesn't expose this via InputEventKey)
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
	if not event is InputEventKey or not event.pressed:
		return

	if event.keycode == KEY_CAPSLOCK:
		caps_lock = !caps_lock
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
	var shift_active = event.shift_pressed or caps_lock

	# Letters
	if event.keycode >= KEY_A and event.keycode <= KEY_Z:
		var letter = char(event.keycode)
		return letter.to_upper() if shift_active else letter.to_lower()

	# Number row
	if event.keycode >= KEY_0 and event.keycode <= KEY_9:
		if event.shift_pressed:
			return SHIFTED_SYMBOLS.get(event.keycode, "")
		return char(event.keycode)

	# Numpad numbers
	if event.keycode >= KEY_KP_0 and event.keycode <= KEY_KP_9:
		return str(event.keycode - KEY_KP_0)

	# Numpad operators
	match event.keycode:
		KEY_KP_ADD:      return "+"
		KEY_KP_SUBTRACT: return "-"
		KEY_KP_MULTIPLY: return "*"
		KEY_KP_DIVIDE:   return "/"
		KEY_KP_PERIOD:   return "."

	# Symbols
	if event.shift_pressed:
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

func is_shift_active() -> bool:
	return caps_lock

# Reset modifier states when terminal closes
func reset_modifiers():
	caps_lock = false
