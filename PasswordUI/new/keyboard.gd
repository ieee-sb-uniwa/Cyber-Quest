extends Control

# Display Messages
var current_input := ""
var screen_log := ""
var welcome := "Καλώς Ήρθατε!\nΕισάγετε κωδικό:\n>"
var exit_msg := "Το τερματικό έχει ήδη ξεκλειδωθεί.\nΠατήστε Enter για έξοδο.\n"

# Paths label- terminal, primary- basic rules, secondary- extra rules
var label_path := "../Screen/Panel/RichTextLabel1"
var primary_label := "../Primary/RichTextLabel2"
var secondary_label := "../Secondary/Panel/RichTextLabel3"

# Variables for successfull unlock and checks
var input_finalized := false
var success := false
var message_done := false
var showing_exit_message := false
var tablet_text = "Χρήσιμες Πληροφορίες:\n"


func _ready():
	self.connect("visibility_changed", Callable(self, "_on_visibility_changed"))

	for child in get_children():
		if child is Button:
			child.connect("pressed", Callable(self, "_on_button_pressed").bind(child.name))

	if is_visible_in_tree():
		call_deferred("_on_visibility_changed")

	var dob_var1 = generate_dob_variations(Global.dob1)
	var dob_var2 = generate_dob_variations(Global.dob2)
	Global.date_of_birth = dob_var1+dob_var2
	print(Global.date_of_birth) #for debugging

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


# Interactions through numpad
func _on_button_pressed(button_name: String):
	if input_finalized:
		return

	if showing_exit_message:
		if button_name == "✔":
			_on_confirm_pressed()
		return

	if message_done:
		match button_name:
			"X":
				if current_input.length() > 0:
					current_input = current_input.substr(0, current_input.length() - 1)
			"✔":
				_on_confirm_pressed()
				return
			_:
				current_input += button_name

	var label = get_node(label_path)

	label.text = screen_log + current_input
	label.scroll_to_line(label.get_line_count() - 1)


# Checking validity
func _on_confirm_pressed():
	input_finalized = true

	if showing_exit_message:
		_successful_unlock()

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
		feedback += "[color=green]✔ Ο κωδικός είναι έγκυρος! Πατήστε Enter για έξοδο.[/color]\n"
		success = true
	else:
		for error in errors:
			feedback += "[color=red]✘ " + error + "\n[/color]"
		feedback += "Εισάγετε νέο κωδικό:\n> "

	return feedback


# Confirm works upon all Enter buttons and on-screen confirm button
func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ENTER and success:
		_successful_unlock()


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
