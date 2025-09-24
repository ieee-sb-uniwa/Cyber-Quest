extends Control

var current_input := ""
var screen_log := "" # For attempts >1
var welcome := "Καλώς Ήρθατε!\nΕισάγετε κωδικό:\n>"
var exit_msg := "Το τερματικό έχει ήδη ξεκλειδωθεί.\nΠατήστε Enter για έξοδο.\n"
var label_path := "../Screen/Panel/RichTextLabel1"
var date_of_birth := ["07022008", "02072008", "07200802", "02200807", "20080702", "20080207"] # Will be set dynamically in intro (02/07/2008 for eg.)
var input_finalized := false
var unlocked_rules := []   # List for tablet rules
var tablet_label := "../Secondary/Panel/RichTextLabel3"
var success := false

# Called when the node enters the scene tree for the first time.
func _ready():
	self.connect("visibility_changed", Callable(self, "_on_visibility_changed"))

	# Connect buttons
	for child in get_children():
		if child is Button:
			child.connect("pressed", Callable(self, "_on_button_pressed").bind(child.name))

	# If this control is already visible when ready, ensure the handler runs:
	if is_visible_in_tree():
		# schedule the visibility handler to run after this frame
		call_deferred("_on_visibility_changed")
		
# New function to handle visibility change
func _on_visibility_changed():
	#print("Password UI visibility changed: ", self.visible)
	var label = get_node(label_path)
	label.bbcode_enabled = true
	label.scroll_active = true
	label.clear()

	# Reset state
	screen_log = ""
	current_input = ""
	input_finalized = false

	# If terminals is not unlocked, show welcome message with typing animation
	if !Global.terminal_unlocked:
		# start the coroutine deferred so we don't block the signal handling
		call_deferred("_start_welcome_animation")
	else:
		call_deferred("_start_exit_animation")


func _start_welcome_animation() -> void:
	var label = get_node(label_path)
	await _type_text_animation(welcome, label, true)
	# keep an accurate screen_log copy for later input display
	screen_log = welcome


func _start_exit_animation() -> void:
	var label = get_node(label_path)
	label.text=""
	
	await _type_text_animation(exit_msg, label, true)

func _type_text_animation(text_to_type: String, label: RichTextLabel, clear_first: bool = false) -> void:
	if clear_first:
		label.clear()

	var base_text := label.text
	var buffer := ""
	
	for ch in text_to_type:
		buffer += ch
		
		# Assign text only once per frame
		await get_tree().process_frame
		label.text = base_text + buffer


func _on_button_pressed(button_name: String):
	if input_finalized:
		return

	match button_name:
		"X":
			if current_input.length() > 0:
				current_input = current_input.substr(0, current_input.length() - 1)
		"✔":
			_on_confirm_pressed()
			return
		_:
			current_input += button_name

	# Keeps old and new input/output on screen
	var label = get_node(label_path)
	label.text = screen_log + current_input
	label.scroll_to_line(label.get_line_count() - 1)


func _on_confirm_pressed():
	input_finalized = true

	var feedback := _generate_rule_feedback()
	screen_log += current_input + "\n" + feedback

	var label = get_node(label_path)
	label.text = screen_log
	label.scroll_to_line(label.get_line_count() - 1)

	current_input = ""
	input_finalized = false


func _generate_rule_feedback() -> String:
	var password := current_input
	var feedback := "> " + password + "\n"

	var rule1_failed := _rule_breach_regex(password, "^\\d{8,}$") # Must be at least 8 digits
	var rule2_failed := _rule_breach_regex(password, "^(?!.*(\\d)\\1).*$") # No two same digits in a row
	var rule3_failed := _rule_breach_regex(password, "^(?!.*(01|12|23|34|45|56|67|78|89|98|87|76|65|54|43|32|21|10)).*$")  # No sequences
	var dob_pattern = "(" + String(",").join(date_of_birth).replace(",", "|") + ")"
	var rule4_failed = _rule_breach_regex(password, "^(?!.*" + dob_pattern + ").*$")  # No DOB07022008

	var errors := []
	var tablet_rules := []

	if rule1_failed:
		errors.append("Μήκος κωδικού τουλάχιστον 8 χαρακτήρες.")

	if rule2_failed:
		errors.append("2 συνεχόμενα νούμερα του κωδικού να μην είναι ίδια")
		tablet_rules.append("2 συνεχόμενα νούμερα του κωδικού να μην είναι ίδια")

	if rule3_failed:
		errors.append("2 συνεχόμενα νούμερα να μην είναι σε σειρά ή αντίστροφα")
		tablet_rules.append("2 συνεχόμενα νούμερα να μην είναι σε σειρά ή αντίστροφα")

	if rule4_failed:
		errors.append("Μην βάλεις την ημερομηνία γέννησής σου")

	# Updates tablet rules
	for rule in tablet_rules:
		if not rule in unlocked_rules:
			unlocked_rules.append(rule)

	var info_label = get_node(tablet_label)

	if unlocked_rules.size() > 0:
		var rules_text = "Χρήσιμες πληροφορίες:\n"
		for rule in unlocked_rules:
			rules_text += "\n" + rule + "\n"
		info_label.text = rules_text

	if errors.size() == 0:
		feedback += "[color=green]✔ Ο κωδικός είναι έγκυρος! Πατήστε Enter για έξοδο.[/color]\n"
		success = true
	else:
		for error in errors:
			feedback += "[color=red]✘ " + error + "\n[/color]"
		feedback += "Εισάγετε νέο κωδικό:\n> "

	return feedback

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ENTER and success:
		_successful_unlock()

func _successful_unlock():
	get_tree().paused = false
	Global.terminal_unlocked = true
	get_parent().visible = false # hide the control node of the ui
	Global.can_pause_game = true

func _rule_breach_regex(password: String, pattern: String) -> bool: # if it matches it returns false
	var regex := RegEx.new()
	var error := regex.compile(pattern)
	if error != OK:
		print("Invalid regex pattern")
		return true
	return regex.search(password) == null
