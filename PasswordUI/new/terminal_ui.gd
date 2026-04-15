extends Control

# Display Messages
var current_input := ""
var screen_log := ""
var welcome := "Καλώς Ήρθατε!\nΕισάγετε κωδικό:\n>"
var exit_msg := "Το τερματικό έχει ήδη ξεκλειδωθεί.\nΠατήστε Enter για έξοδο.\n"

# Paths label- terminal, secondary- extra rules
var terminal_label := "Screen/RichTextLabel1"
var tablet_label := "Secondary/RichTextLabel3"

# Variables for successful unlock and checks
var input_finalized := false
var success := false
var message_done := false
var showing_exit_message := false

@onready var keyboard_manager = $KeyboardContainer/KeyboardLayout
@onready var shift_toggle: Button = $KeyboardContainer/ShiftToggle
@onready var numpad_bg: Control = $KeyboardContainer/NumpadBackground
@onready var letters_bg: Control = $KeyboardContainer/LettersBackground
@onready var symbols_bg: Control = $KeyboardContainer/SymbolsBackground

var input_handler: keyboard_input_handler
var password_validator: PasswordValidator

@export var hasNum : bool = false
@export var hasLetters : bool = false
@export var hasSymbols : bool = true
@export var rules_dialogue: DialogueResource
@onready var balloon_node = $DialogueBalloon

func _ready():
	# Initialize password validator
	password_validator = PasswordValidator.new()
	
	# Initialize global data
	Global.terminal_ui_part["num"] = hasNum
	Global.terminal_ui_part["letters"] = hasLetters
	Global.terminal_ui_part["symbols"] = hasSymbols
	Global.date_of_birth = generate_dob_variations(Global.dob1) + generate_dob_variations(Global.dob2)
	Global.usernames = [Global.user1.to_lower(), Global.user2.to_lower()]

	# Initialize input handler
	input_handler = keyboard_input_handler.new()
	add_child(input_handler)
	input_handler.key_entered.connect(_on_physical_key_pressed)
	
	self.connect("visibility_changed", Callable(self, "_on_visibility_changed"))
	
	# Connect to keyboard_manager's signal for letter/number/symbol keys
	keyboard_manager.key_pressed.connect(_on_keyboard_key_pressed)
	
	# Connect action buttons directly (Enter, Backspace, Cancel)
	_connect_action_buttons()
	
	shift_toggle.toggled.connect(_on_shift_toggled)

	if is_visible_in_tree():
		call_deferred("_on_visibility_changed")

	if is_instance_valid(rules_dialogue):
		balloon_node.start(rules_dialogue, "show_rules", [])
		
	setup_terminal()
	setup_tablet()
	

func _connect_action_buttons():
	# Find Enter button
	var enter_btn = $KeyboardContainer/Enter
	if enter_btn:
		enter_btn.pressed.connect(_on_enter_pressed)
	
	# Find Backspace button
	var backspace_btn = $KeyboardContainer/Backspace
	if backspace_btn:
		backspace_btn.pressed.connect(_on_backspace_pressed)
	
	# Find Cancel button
	var cancel_btn = $KeyboardContainer/Cancel
	if cancel_btn:
		cancel_btn.pressed.connect(_on_cancel_pressed)

func _on_enter_pressed():
	if current_input.is_empty():
		return
	_on_confirm_pressed()

# Handle Backspace button press
func _on_backspace_pressed():
	if current_input.length() > 0:
		current_input = current_input.substr(0, current_input.length() - 1)
		var label = get_node(terminal_label)
		label.text = screen_log + current_input
		label.scroll_to_line(label.get_line_count() - 1)

# Handle Cancel button press
func _on_cancel_pressed():
	current_input = ""
	var label = get_node(terminal_label)
	label.text = screen_log + current_input
	label.scroll_to_line(label.get_line_count() - 1)
	

func _connect_all_buttons(node: Node):
	for child in node.get_children():
		if child is Button:
			# Don't double-connect the shift toggle (it has its own signal)
			if child != shift_toggle:
				if not child.pressed.is_connected(Callable(self, "_on_button_pressed").bind(child.name)):
					child.pressed.connect(Callable(self, "_on_button_pressed").bind(child.name))
		# Recursively check children
		_connect_all_buttons(child)


func setup_tablet():
	var info_label = get_node(tablet_label)
	var text = "Κύριοι Κανόνες:\n"
	var range_end = 3 if hasLetters else 8 if hasSymbols else 1
	for i in range(1, range_end):
		var rule = Global.pri_rules["prule" + str(i)]
		if rule["visible"]:
			text += "\n• " + rule["text"]	

	if text == "Κύριοι Κανόνες:\n":
		text = ""
	else:
		text += "\n\n"

	text += "Δευτερεύοντοι Κανόνες:\n"
	for key in Global.sec_rules:
		var rule = Global.sec_rules[key]
		if rule["visible"]:
			text += "\n• " + rule["text"]

	info_label.text = text


func setup_terminal():

	# True for all parts
	numpad_bg.visible = true
	letters_bg.visible = false
	symbols_bg.visible = false

	if hasNum:
		keyboard_manager.setup_level_layouts(1)
		$KeyboardContainer/ShiftToggle.visible = false
		$KeyboardContainer/ShiftToggle.disabled = true
	elif hasLetters:
		keyboard_manager.setup_level_layouts(2)
		$KeyboardContainer/ShiftToggle.visible = true
		$KeyboardContainer/ShiftToggle.disabled = false
		letters_bg.visible = true
		for i in range(1, 6):
			Global.pri_rules["prule" + str(i)]["visible"] = true
	elif hasSymbols:
		keyboard_manager.setup_level_layouts(3)
		$KeyboardContainer/ShiftToggle.visible = true
		$KeyboardContainer/ShiftToggle.disabled = false
		letters_bg.visible = true
		symbols_bg.visible = true
		for i in range(1, 7):
			Global.pri_rules["prule" + str(i)]["visible"] = true

# Terminal activation
func _on_visibility_changed():
	if not is_visible_in_tree():
		input_handler.reset_modifiers()
		return
	var label = get_node(terminal_label)

	label.bbcode_enabled = true
	label.scroll_active = true
	label.clear()

	screen_log = ""
	current_input = ""
	input_finalized = false

	if !Global.terminal_unlocked:
		call_deferred("_start_welcome_animation")
	else:
		showing_exit_message = true
		call_deferred("_start_exit_animation")


# Welcome message animation
func _start_welcome_animation() -> void:
	var label = get_node(terminal_label)

	await _type_text_animation(welcome, label, true)
	screen_log = welcome
	message_done = true


# Exit message animation
func _start_exit_animation() -> void:
	message_done = false
	var label = get_node(terminal_label)
	label.text = ""

	await _type_text_animation(exit_msg, label, true)

	message_done = true


# Animation timeframes
func _type_text_animation(text_to_type: String, label: RichTextLabel, clear_first: bool = false) -> void:
	var frames_per_char := 6

	if clear_first:
		label.clear()

	var base_text := label.text
	var buffer := ""

	for ch in text_to_type:
		buffer += ch
		for i in range(frames_per_char):
			if get_tree() == null:
				return
			await get_tree().create_timer(0.016).timeout 
			label.text = base_text + buffer

func _on_keyboard_key_pressed(key_value: String, key_type: String):
	if not is_visible_in_tree():
		return
	if input_finalized:
		return
	
	if showing_exit_message:
		return
	
	if message_done:
		# Apply shift/caps lock to the character if it's a letter
		var final_char = key_value
		if key_type == "letter" and input_handler and input_handler.is_shift_active():
			final_char = key_value.to_upper()
		
		if _is_character_allowed(final_char):
			current_input += final_char
	
	var label = get_node(terminal_label)
	label.text = screen_log + current_input
	label.scroll_to_line(label.get_line_count() - 1)


# Checking validity
func _on_confirm_pressed():

	input_finalized = true

	if showing_exit_message:
		_successful_unlock()
		return

	if not success:
		var validation_result = password_validator.generate_rule_feedback(current_input, hasNum, hasLetters, hasSymbols)
		var feedback = validation_result[0]
		success = validation_result[1]
		
		screen_log += current_input + "\n" + feedback
		
		# Update tablet with visible rules
		setup_tablet()

		var label = get_node(terminal_label)
		label.text = screen_log
		label.scroll_to_line(label.get_line_count() - 1)

		current_input = ""
		input_finalized = false
	else:
		_successful_unlock()


		
# DOB variations function
func generate_dob_variations(dob_str: String) -> Array:
	var parts = dob_str.split("/") #Assuming dob is in format 07/02/2008

	var day = parts[0]
	var month = parts[1]
	var year = parts[2]

	# All possible variations
	var permutations = [
		[day, month, year],
		[month, day, year],
		[day, year, month],
		[month, year, day],
		[year, month, day],
		[year, day, month]
	]

	var variations = []

	for p in permutations: # All variations in form "07022008"
		var padded = p[0] + p[1] + p[2]
		variations.append(padded)
		
		var unpadded_vars = []
		
		for item in p:
				# Remove leading zero only if present
			if item.begins_with("0"):
				unpadded_vars.append(item.substr(1))
			else:
				unpadded_vars.append(item)
		var unpadded = unpadded_vars[0] + unpadded_vars[1] + unpadded_vars[2]
		variations.append(unpadded)

	return variations

func _on_shift_toggled(button_pressed: bool):
	if hasNum:
		return
	
	# Sync caps lock with button state
	while input_handler.is_shift_active() != button_pressed:
		input_handler.toggle_caps_lock()
	
	# Just update the keyboard manager's state - DON'T recreate keys
	keyboard_manager.is_uppercase = button_pressed
	
	# Update the display of existing letter keys
	_update_letter_keys_case(button_pressed)
	
	print("Shift toggled - Caps Lock: ", button_pressed)

# New function to update letter keys without recreating them
func _update_letter_keys_case(uppercase: bool):
	# Find all letter buttons and update their text
	var containers = [numpad_bg, letters_bg, symbols_bg]
	for container in containers:
		if container:
			_update_buttons_in_container(container, uppercase)

func _update_buttons_in_container(container: Control, uppercase: bool):
	for child in container.get_children():
		if child is Button:
			var current_text = child.text
			# Only update letters (a-z, A-Z)
			if current_text.length() == 1 and current_text.to_lower() != current_text.to_upper():
				if uppercase:
					child.text = current_text.to_upper()
				else:
					child.text = current_text.to_lower()
		# Recursively check children
		_update_buttons_in_container(child, uppercase)

# Confirm works upon all Enter buttons and on-screen confirm button
func _input(event):
	if not is_visible_in_tree():
		return
	if event is InputEventKey and event.pressed and event.keycode == KEY_ENTER and success:
		_successful_unlock()
	
# Success maintains the terminal unlocked on next interactions
func _successful_unlock():
	get_tree().paused = false
	Global.terminal_unlocked = true
	get_parent().visible = false
	Global.can_pause_game = true

# Character input filtering
func _is_character_allowed(character: String) -> bool:
	if character.length() == 0:
		return false
		
	if hasNum:
		# Only numbers allowed (0-9)
		return character >= "0" and character <= "9"
	elif hasLetters:
		# Numbers and letters allowed (both lowercase and uppercase)
		var c = character.to_lower()
		# Check if it's a number or a letter (a-z)
		var is_letter = (c >= "a" and c <= "z")
		var is_number = (character >= "0" and character <= "9")
		
		# If shift is active, allow both cases of letters
		if keyboard_manager.is_uppercase:
			# Allow both uppercase and lowercase letters
			return is_number or (character >= "A" and character <= "Z") or (character >= "a" and character <= "z")
		else:
			# Only allow lowercase letters
			return is_number or (character >= "a" and character <= "z")
	else:
		# All characters allowed (symbols mode)
		return true

# ADDED: Handle physical keyboard input
func _on_physical_key_pressed(key_value: String, _key_type: String):
	if not is_visible_in_tree():
		return
	if input_finalized:
		return
	
	if showing_exit_message:
		if key_value == "✔":
			_on_confirm_pressed()
		return
	
	if message_done:
		match key_value:
			"X":
				if current_input.length() > 0:
					current_input = current_input.substr(0, current_input.length() - 1)
			"Cancel":
				current_input = ""
			"✔":
				if current_input.is_empty():
					return
				_on_confirm_pressed()
				return
			_:
				if _is_character_allowed(key_value):
					current_input += key_value
	
	var label = get_node(terminal_label)
	label.text = screen_log + current_input
	label.scroll_to_line(label.get_line_count() - 1)
