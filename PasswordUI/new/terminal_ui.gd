extends Control

# Display Messages
var current_input := ""
var screen_log := ""
var welcome := "Καλώς Ήρθατε!\nΕισάγετε κωδικό:\n>"
var exit_msg := "Το τερματικό έχει ήδη ξεκλειδωθεί.\nΠατήστε Enter για έξοδο.\n"

# Paths label- terminal, primary- basic rules, secondary- extra rules
var label_path := "Screen/RichTextLabel1"
var primary_label := "Primary/RichTextLabel2"
var secondary_label := "Secondary/RichTextLabel3"

# Variables for successfull unlock and checks
var input_finalized := false
var success := false
var message_done := false
var showing_exit_message := false
var tablet_text = "Χρήσιμες Πληροφορίες:\n"

@onready var keyboard_manager = $KeyboardContainer/KeyboardLayout

@onready var shift_toggle: Button = $KeyboardContainer/ShiftToggle
@onready var numpad_bg: Control = $KeyboardContainer/NumpadBackground
@onready var letters_bg: Control = $KeyboardContainer/LettersBackground
@onready var symbols_bg: Control = $KeyboardContainer/SymbolsBackground

@onready var enter_button: Button = $KeyboardContainer/Enter
@onready var backspace_button: Button = $KeyboardContainer/Backspace
@onready var cancel_button: Button = $KeyboardContainer/Cancel

@export var hasNum : bool = false
@export var hasLetters : bool = false
@export var hasSymbols : bool = true

func _ready():
	self.connect("visibility_changed", Callable(self, "_on_visibility_changed"))
	# Connect keyboard manager signals
	keyboard_manager.key_pressed.connect(_on_keyboard_key_pressed)
	
	# Connect button signals
	enter_button.pressed.connect(_on_confirm_pressed)
	backspace_button.pressed.connect(_on_backspace_pressed)
	cancel_button.pressed.connect(_on_cancel_pressed)
	shift_toggle.toggled.connect(_on_shift_toggled)


	if is_visible_in_tree():
		call_deferred("_on_visibility_changed")

	var dob_var1 = generate_dob_variations(Global.dob1)
	var dob_var2 = generate_dob_variations(Global.dob2)
	Global.date_of_birth = dob_var1+dob_var2
	# print(Global.date_of_birth) #for debugging

	# Show only visible primary rules from the start
	var primary_label_node = get_node(primary_label)
	var text = "Βασικοί Κανόνες:\n\n"

	var secondary_label_node = get_node(secondary_label)
	var sec_text = "Χρήσιμες Πληροφορίες:\n\n"

	Global.visible_pri_rules["prule1"]=true
	Global.visible_pri_rules["prule2"]=true

	for key in Global.pri_rules.keys():
		if Global.visible_pri_rules[key]:
			text += Global.pri_rules[key] + "\n\n"

	primary_label_node.text = text
	
	secondary_label_node.text = sec_text
	tablet_text = sec_text

	setup_terminal()

func setup_terminal():

	numpad_bg.visible = false
	letters_bg.visible = false
	symbols_bg.visible = false
	shift_toggle.visible = false

	if hasNum:
		keyboard_manager.setup_level_layouts(1)
		numpad_bg.visible = true
		print(PlayerData.level)
			
	elif hasLetters:
		keyboard_manager.setup_level_layouts(2)
		numpad_bg.visible = true
		letters_bg.visible = true
		shift_toggle.visible = true
		print(PlayerData.level)
			
	elif hasSymbols:
		keyboard_manager.setup_level_layouts(3)
		numpad_bg.visible = true
		letters_bg.visible = true
		shift_toggle.visible = true
		symbols_bg.visible = true
		print(PlayerData.level)

# Keyboard key pressed handler
func _on_keyboard_key_pressed(key_value: String, _key_type: String):
	if input_finalized:
		return

	if showing_exit_message:
		return

	if message_done:
		# Add the key to current input
		current_input += key_value
		_update_display()

# Backspace handler
func _on_backspace_pressed():
	if input_finalized:
		return

	if showing_exit_message:
		return

	if message_done and current_input.length() > 0:
		current_input = current_input.substr(0, current_input.length() - 1)
		_update_display()

# Cancel (X) handler - clears entire line
func _on_cancel_pressed():
	if input_finalized:
		return

	if showing_exit_message:
		return

	if message_done:
		current_input = ""
		_update_display()

func _update_display():
	var label = get_node(label_path)
	var display_text = screen_log + current_input + "_"  # Add cursor
	label.text = display_text
	label.scroll_to_line(label.get_line_count() - 1)


# Terminal activation
func _on_visibility_changed():
	var label = get_node(label_path)

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
	var label = get_node(label_path)

	await _type_text_animation(welcome, label, true)
	screen_log = welcome
	message_done = true


# Exit message animation
func _start_exit_animation() -> void:
	message_done = false
	var label = get_node(label_path)
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


# Checking validity
func _on_confirm_pressed():

	input_finalized = true

	if showing_exit_message:
		_successful_unlock()
		return

	if not success:
		var feedback := _generate_rule_feedback()
		screen_log += current_input + "\n" + feedback

		var label = get_node(label_path)
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
	keyboard_manager.toggle_uppercase(button_pressed)


# On screen feedback after check
func _generate_rule_feedback() -> String:
	var password := current_input
	var feedback := "> " + password + "\n"

	# Primary rules check
	var dob_pattern = "(" + String(",").join(Global.date_of_birth).replace(",", "|") + ")" #turns date_of_birth array to regex
	var prule1_failed = _rule_breach_regex(password, "^(?!.*" + dob_pattern + ").*$")  # no DOB
	var prule2_failed = password.length() < 8  # length >= 8

	# Secondary rules check
	var srule1_failed = _rule_breach_regex(password, "^(?!.*(\\d)\\1).*$")  # no same digits in a row
	var srule2_failed = _rule_breach_regex(password, "^(?!.*(01|12|23|34|45|56|67|78|89|98|87|76|65|54|43|32|21|10)).*$")  # no sequences

	var errors := []

	# Primary rules violation gets shown on terminal
	if prule1_failed:
		errors.append(Global.pri_rules["prule1"])
	if prule2_failed:
		errors.append(Global.pri_rules["prule2"])

	# Secondary rules get shown on terminal and are revealed in secondary tablet only after failure
	if srule1_failed:
		errors.append(Global.sec_rules["srule1"])
		Global.visible_sec_rules["srule1"] = true
	if srule2_failed:
		errors.append(Global.sec_rules["srule2"])
		Global.visible_sec_rules["srule2"] = true

	# Tablet update after secondary rule failure
	var info_label = get_node(secondary_label)
	var sec_text = "Χρήσιμες Πληροφορίες:\n"
	for key in Global.sec_rules.keys():
		if Global.visible_sec_rules[key]:
			sec_text += "\n" + Global.sec_rules[key] + "\n"
	info_label.text = sec_text
	tablet_text = sec_text

	# Feedback on terminal (colorized)
	if errors.size() == 0:
		feedback += "[color=0cc5cc]Ο κωδικός είναι έγκυρος! Πατήστε Enter για έξοδο.[/color]\n"
		success = true
	else:
		for error in errors:
			feedback += "[color=ef6e2f]" + error + "\n[/color]"
		feedback += "Εισάγετε νέο κωδικό:\n> "

	return feedback

# Confirm works upon all Enter buttons and on-screen confirm button
func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ENTER and success:
		_successful_unlock()
	
func _user_input(event):
	if input_finalized or showing_exit_message:
		return
	
	if event is InputEventKey and event.pressed:
		# Handle hardware keyboard input
		if event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
			_on_confirm_pressed()
		elif event.keycode == KEY_BACKSPACE:
			_on_backspace_pressed()
		elif event.keycode == KEY_ESCAPE:
			_on_cancel_pressed()
		elif event.keycode == KEY_SHIFT:
			# Toggle shift
			shift_toggle.button_pressed = !shift_toggle.button_pressed
			_on_shift_toggled(shift_toggle.button_pressed)
		else:
			# Convert keycode to character for regular keys
			var character = event.as_text()
			if character.length() == 1:  # Single character
				current_input += character
				_update_display()

# Success maintains the terminal unlocked on next interactions
func _successful_unlock():
	get_tree().paused = false
	Global.terminal_unlocked = true
	get_parent().visible = false
	Global.can_pause_game = true

# Regex validation
func _rule_breach_regex(password: String, pattern: String) -> bool:
	var regex := RegEx.new()
	if regex.compile(pattern) != OK:
		return true
	return regex.search(password) == null
