class_name PasswordValidator

# Regex validation
func rule_breach_regex(password: String, pattern: String) -> bool:
	var regex := RegEx.new()
	if regex.compile(pattern) != OK:
		return true
	return regex.search(password) == null

# Apply rules and collect errors
func apply_rules(password: String, from: int, to: int, type_rule: String) -> Array:
	var rules = Global.pri_rules if type_rule == "prule" else Global.sec_rules
	var errors := []
	var is_primary = type_rule == "prule"

	for i in range(from, to):
		var key = type_rule + str(i)
		var pattern = rules[key]["regex"]
		if not pattern.is_empty():
			if rule_breach_regex(password, pattern):
				errors.append({
					"text": rules[key]["text"],
					"is_primary": is_primary
				})
				rules[key]["visible"] = true
	return errors

# Generate feedback from password validation
func generate_rule_feedback(password: String, hasNum: bool, hasLetters: bool, hasSymbols: bool) -> Array:
	var errors := []
	var feedback := ""

	# Apply primary rules
	if hasNum:
		Global.pri_rules["prule1"]["regex"] = "^(?!.*(" + "|".join(Global.date_of_birth) + ")).*$"
		errors += apply_rules(password, 1, 3, "prule")
	elif hasLetters:
		Global.pri_rules["prule3"]["regex"] = "^(?!.*(" + "|".join(Global.usernames) + ")).*$"
		errors += apply_rules(password, 1, 7, "prule")
	elif hasSymbols:
		errors += apply_rules(password, 1, 8, "prule")
	
	# Apply secondary rules
	if hasNum:
		errors += apply_rules(password, 1, 3, "srule")
	elif hasLetters:
		errors += apply_rules(password, 1, 6, "srule")
	elif hasSymbols:
		errors += apply_rules(password, 1, 7, "srule")

	# Feedback on terminal (colorized)
	var success = false
	if errors.size() == 0:
		feedback += "[color=27c2da]Ο κωδικός είναι έγκυρος! Πατήστε Enter για έξοδο.[/color]\n"
		success = true
	else:
		for error in errors:
			var color = "ef6e2f" if error["is_primary"] else "e94238"
			feedback += "[color=" + color + "]" + error["text"] + "\n[/color]"
		
	return [feedback + ">", success]
