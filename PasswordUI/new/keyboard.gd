# Doesn't work from keyboard
# New try erases screen's old output
# Hide tablet info until mistake has been made. (When mistake has been made then "unlock" it in the tablet)

extends Control

var current_input := ""
var welcome1 := "Welcome!\n"
var welcome2 := "Please enter password:\n >"
var label_path := "../Screen/Panel/RichTextLabel1"
var date_of_birth = "07022008" # Will be set dynamically in intro (02/07/2008 for eg.)
var input_finalized := false

func _ready():
	var label = get_node(label_path)
	label.clear()
	label.bbcode_enabled = true
	label.scroll_active = true

	await _type_text_animation(welcome1, label)
	await _type_text_animation(welcome2, label)

	# connect all buttons in keyboard
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

	# Keyboard button pressed
	match button_name:
		"X":
			if current_input.length() > 0:
				current_input = current_input.substr(0, current_input.length() - 1)
		"✔":
			_on_confirm_pressed()
			return
		_:
			current_input += button_name

	# update input display
	var label = get_node(label_path)
	label.text = welcome1 + welcome2 + current_input


func _on_confirm_pressed():
	input_finalized = true

	var label = get_node(label_path)
	var feedback := _generate_rule_feedback()

	label.append_text("\n" + feedback + "\n")

	# prepare for next input
	current_input = ""
	input_finalized = false


func _generate_rule_feedback() -> String:
	var password := current_input
	var feedback := "> " + password + "\n"

	var rule1_failed := _rule_breach_regex(password, "^\\d{8,}$") # Must be at least 8 digits
	var rule2_failed := _rule_breach_regex(password, "^(?!.*(\\d)\\1).*$") # No two same digits in a row
	var rule3_failed := _rule_breach_regex(password, "^(?!.*(01|12|23|34|45|56|67|78|89|98|87|76|65|54|43|32|21|10)).*$")  # No sequences
	var rule4_failed := _rule_breach_regex(password, "^(?!.*" + date_of_birth + ").*$")  # No DOB

	var errors := []
	
	if rule1_failed:
		errors.append("Μήκος κωδικού τουλάχιστον 8 χαρακτήρες.")
	if rule2_failed:
		errors.append("2 συνεχόμενα νούμερα του κωδικού να μην είναι ίδια")
	if rule3_failed:
		errors.append("2 συνεχόμενα νούμερα να μην είναι σε σειρά ή αντίστροφα")
	if rule4_failed:
		errors.append("Μην βάλεις την ημερομηνία γέννησής σου")

	if errors.size() == 0:
		feedback += "[color=green]✔ Valid Password![/color]\n"
	else:
		for error in errors:
			feedback += "[color=red]✘ " + error + "\n[/color]"
		feedback += "Input password:\n> "

	return feedback

func _rule_breach_regex(password: String, pattern: String) -> bool: # if it matches it returns false
	var regex := RegEx.new()
	var error := regex.compile(pattern)
	if error != OK:
		print("Invalid regex pattern")
		return true
	return regex.search(password) == null