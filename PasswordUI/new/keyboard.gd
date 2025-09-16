extends Control

var current_input := ""
var screen_log := "" # For attempts >1
var welcome1 := "Καλώς Ήρθατε!\n"
var welcome2 := "Εισάγετε κωδικό:\n >"
var label_path := "../Screen/Panel/RichTextLabel1"
var date_of_birth := ["07022008", "02072008", "07200802", "02200807", "20080702", "20080207"] # Will be set dynamically in intro (02/07/2008 for eg.)
var input_finalized := false
var unlocked_rules := []   # List for tablet rules
var tablet_label := "../Secondary/Panel/RichTextLabel3"

func _ready():
	var label = get_node(label_path)
	label.bbcode_enabled = true
	label.scroll_active = true

	await _type_text_animation(welcome1, label)
	await _type_text_animation(welcome2, label)

	screen_log = welcome1 + welcome2

	# Connect buttons
	for child in get_children():
		if child is Button:
			child.connect("pressed", Callable(self, "_on_button_pressed").bind(child.name))


func _type_text_animation(text_to_type: String, label: RichTextLabel) -> void:
	for i in range(text_to_type.length()):
		label.append_text(text_to_type[i])
		await get_tree().create_timer(0.05).timeout

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
		feedback += "[color=green]✔ Ο κωδικός είναι έγκυρος![/color]\n"
	else:
		for error in errors:
			feedback += "[color=red]✘ " + error + "\n[/color]"
		feedback += "Εισάγετε νέο κωδικό:\n> "

	return feedback



func _rule_breach_regex(password: String, pattern: String) -> bool: # if it matches it returns false
	var regex := RegEx.new()
	var error := regex.compile(pattern)
	if error != OK:
		print("Invalid regex pattern")
		return true
	return regex.search(password) == null
