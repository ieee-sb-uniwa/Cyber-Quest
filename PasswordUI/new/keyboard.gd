extends Control

var current_input := ""
var screen_log := ""
var welcome := "Καλώς Ήρθατε!\nΕισάγετε κωδικό:\n>"
var exit_msg := "Το τερματικό έχει ήδη ξεκλειδωθεί.\nΠατήστε Enter για έξοδο.\n"

var label_path := "../Screen/Panel/RichTextLabel1"
var primary_label := "../Primary/RichTextLabel2"
var tablet_label := "../Secondary/Panel/RichTextLabel3"

var input_finalized := false
var success := false
var message_done := false
var showing_exit_message := false


# --- Rules ---
var pri_rules := {
	"prule1": "Μην βάλεις την ημερομηνία γέννησής σου.",
	"prule2": "Μήκος κωδικού τουλάχιστον 8 ψηφία.",
	"prule3": "Μην βάλεις το όνομά σου.",
	"prule4": "Βάλε τουλάχιστον ένα κεφαλαίο γράμμα.",
	"prule5": "Βάλε τουλάχιστον ένα πεζό γράμμα.",
	"prule6": "Βάλε τουλάχιστον έναν αριθμό.",
	"prule7": "Βάλε τουλάχιστον ένα ειδικό σύμβολο."
}

var sec_rules := {
	"srule1": "2 συνεχόμενα νούμερα να μην είναι ίδια.",
	"srule2": "2 συνεχόμενα νούμερα να μην είναι σε σειρά ή αντίστροφα.",
	"srule3": "2 συνεχόμενα γράμματα να μην είναι ίδια.",
	"srule4": "2 συνεχόμενα γράμματα να μην είναι σε σειρά ή αντίστροφα.",
	"srule5": "Να μην υπάρχουν 3 συνεχόμενα ψηφία.",
	"srule6": "Να μην υπάρχουν 3 συνεχόμενα ειδικά σύμβολα."
}

# --- Visibility ---
var visible_pri_rules := {
	"prule1": true,   # visible from start
	"prule2": true,   # visible from start
	"prule3": false,
	"prule4": false,
	"prule5": false,
	"prule6": false,
	"prule7": false
}

var visible_sec_rules := {
	"srule1": false,  # revealed on fail
	"srule2": false,  # revealed on fail
	"srule3": false,
	"srule4": false,
	"srule5": false,
	"srule6": false
}


# --- Function to create all possible DOB patterns ---
func generate_dob_variations(dob_str: String) -> Array:
	var parts = dob_str.split("/")
	if parts.size() != 3:
		return []

	var day = parts[0]
	var month = parts[1]
	var year = parts[2]

	if year.length() == 2:
		year = "20" + year

	var permutations = [
		[day, month, year],
		[month, day, year],
		[day, year, month],
		[month, year, day],
		[year, month, day],
		[year, day, month]
	]

	var variations = []
	for p in permutations:
		variations.append(p[0] + p[1] + p[2])

	return variations


# --- On ready ---
func _ready():
	self.connect("visibility_changed", Callable(self, "_on_visibility_changed"))

	for child in get_children():
		if child is Button:
			child.connect("pressed", Callable(self, "_on_button_pressed").bind(child.name))

	if is_visible_in_tree():
		call_deferred("_on_visibility_changed")

	Global.date_of_birth = generate_dob_variations(Global.dob)
	print(Global.date_of_birth)

	# Show only visible primary rules
	var primary_label_node = get_node(primary_label)
	var sectext = "Βασικοί Κανόνες:\n\n"
	for key in pri_rules.keys():
		if visible_pri_rules[key]:
			sectext += "- " + pri_rules[key] + "\n"
	primary_label_node.text = sectext


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


func _start_welcome_animation() -> void:
	var label = get_node(label_path)
	await _type_text_animation(welcome, label, true)
	screen_log = welcome
	message_done = true


func _start_exit_animation() -> void:
	message_done = false
	var label = get_node(label_path)
	label.text = ""
	await _type_text_animation(exit_msg, label, true)
	message_done = true


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


func _generate_rule_feedback() -> String:
	var password := current_input
	var feedback := "> " + password + "\n"

	# --- Primary rules ---
	var dob_pattern = "(" + String(",").join(Global.date_of_birth).replace(",", "|") + ")"
	var prule1_failed = _rule_breach_regex(password, "^(?!.*" + dob_pattern + ").*$")  # no DOB
	var prule2_failed = password.length() < 8  # length >= 8

	# --- Secondary rules ---
	var srule1_failed = _rule_breach_regex(password, "^(?!.*(\\d)\\1).*$")  # no same digits in a row
	var srule2_failed = _rule_breach_regex(password, "^(?!.*(01|12|23|34|45|56|67|78|89|98|87|76|65|54|43|32|21|10)).*$")  # no sequences

	var errors := []

	# --- Primary rule failures (always shown) ---
	if prule1_failed:
		errors.append(pri_rules["prule1"])
	if prule2_failed:
		errors.append(pri_rules["prule2"])

	# --- Secondary rules (revealed dynamically) ---
	if srule1_failed:
		errors.append(sec_rules["srule1"])
		visible_sec_rules["srule1"] = true
	if srule2_failed:
		errors.append(sec_rules["srule2"])
		visible_sec_rules["srule2"] = true

	# --- Update tablet info (only visible ones) ---
	var info_label = get_node(tablet_label)
	var tablet_text = "Χρήσιμες Πληροφορίες:\n"
	for key in sec_rules.keys():
		if visible_sec_rules[key]:
			tablet_text += "\n" + sec_rules[key] + "\n"
	info_label.text = tablet_text

	# --- Feedback display ---
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
	get_parent().visible = false
	Global.can_pause_game = true


func _rule_breach_regex(password: String, pattern: String) -> bool:
	var regex := RegEx.new()
	if regex.compile(pattern) != OK:
		return true
	return regex.search(password) == null
