# PasswordValidator.gd
extends RefCounted

class_name password_validator

# Variables to track discovered secondary rules
var visible_sec_rules: Dictionary = {
	"srule1": false,
	"srule2": false,
	"srule3": false,
	"srule4": false,
	"srule5": false,
	"srule6": false
}

var date_of_birth: Array = []
var usernames: Array = []  # Store usernames for checking

func _init():
	pass

func setup_data(dob: Array, username1: String, username2: String):
	date_of_birth = dob
	usernames.clear()
	if username1 != "":
		usernames.append(username1)
	if username2 != "":
		usernames.append(username2)

func validate_password(password: String, hasNum: bool, hasLetters: bool, hasSymbols: bool) -> Dictionary:
	var result = {
		"success": false,
		"primary_errors": [],
		"secondary_errors": [],
		"primary_rules_to_show": [],
		"secondary_rules_to_show": []
	}
	
	# Determine which rules to check based on level
	if hasNum:
		result = _validate_level1(password)
	elif hasLetters:
		result = _validate_level2(password)
	elif hasSymbols:
		result = _validate_level3(password)
	
	# Build the list of rules to show based on current level
	if hasNum:
		result["primary_rules_to_show"] = ["prule1", "prule2"]
	elif hasLetters:
		result["primary_rules_to_show"] = ["prule1", "prule2", "prule3", "prule4", "prule5", "prule6"]
	elif hasSymbols:
		result["primary_rules_to_show"] = ["prule1", "prule2", "prule3", "prule4", "prule5", "prule6", "prule7"]
	
	# Build list of discovered secondary rules to show
	result["secondary_rules_to_show"] = []
	for key in visible_sec_rules.keys():
		if visible_sec_rules[key]:
			result["secondary_rules_to_show"].append(key)
	
	result["success"] = result["primary_errors"].size() == 0 and result["secondary_errors"].size() == 0
	
	return result

func _validate_level1(password: String) -> Dictionary:
	var primary_errors = []
	var secondary_errors = []
	
	# Primary rules for Level 1
	if date_of_birth.size() > 0:
		var dob_pattern = "(" + String(",").join(date_of_birth).replace(",", "|") + ")"
		if _rule_breach_regex(password, "^(?!.*" + dob_pattern + ").*$"):
			primary_errors.append("prule1")
	
	if password.length() < 8:
		primary_errors.append("prule2")
	
	# Secondary rules for Level 1
	if _rule_breach_regex(password, "^(?!.*(\\d)\\1).*$"):
		secondary_errors.append("srule1")
		visible_sec_rules["srule1"] = true
	
	if _rule_breach_regex(password, "^(?!.*(01|12|23|34|45|56|67|78|89|98|87|76|65|54|43|32|21|10)).*$"):
		secondary_errors.append("srule2")
		visible_sec_rules["srule2"] = true
	
	return {
		"primary_errors": primary_errors,
		"secondary_errors": secondary_errors
	}

func _validate_level2(password: String) -> Dictionary:
	var primary_errors = []
	var secondary_errors = []
	
	# Primary rules for Level 2
	if date_of_birth.size() > 0:
		var dob_pattern = "(" + String(",").join(date_of_birth).replace(",", "|") + ")"
		if _rule_breach_regex(password, "^(?!.*" + dob_pattern + ").*$"):
			primary_errors.append("prule1")
	
	if password.length() < 8:
		primary_errors.append("prule2")
	
	# Check usernames
	var username_pattern = ""
	for username in usernames:
		if username_pattern != "":
			username_pattern += "|"
		username_pattern += username
	
	if username_pattern != "" and _rule_breach_regex(password, "^(?!.*" + username_pattern + ").*$"):
		primary_errors.append("prule3")
	
	if _rule_breach_regex(password, "^(?=.*[A-Z]).*$"):
		primary_errors.append("prule4")
	
	if _rule_breach_regex(password, "^(?=.*[a-z]).*$"):
		primary_errors.append("prule5")
	
	if _rule_breach_regex(password, "^(?=.*[0-9]).*$"):
		primary_errors.append("prule6")
	
	# Secondary rules for Level 2 (include Level 1 rules + new ones)
	if _rule_breach_regex(password, "^(?!.*(\\d)\\1).*$"):
		secondary_errors.append("srule1")
		visible_sec_rules["srule1"] = true
	
	if _rule_breach_regex(password, "^(?!.*(01|12|23|34|45|56|67|78|89|98|87|76|65|54|43|32|21|10)).*$"):
		secondary_errors.append("srule2")
		visible_sec_rules["srule2"] = true
	
	if _rule_breach_regex(password, "^(?!.*([a-zA-Z])\\1).*$"):
		secondary_errors.append("srule3")
		visible_sec_rules["srule3"] = true
	
	if _rule_breach_regex(password, "^(?!.*(ab|bc|cd|de|ef|fg|gh|hi|ij|jk|kl|lm|mn|no|op|pq|qr|rs|st|tu|uv|vw|wx|xy|yz)).*$", true):
		secondary_errors.append("srule4")
		visible_sec_rules["srule4"] = true
	
	if _rule_breach_regex(password, "^(?!.*\\d{3}).*$"):
		secondary_errors.append("srule5")
		visible_sec_rules["srule5"] = true
	
	return {
		"primary_errors": primary_errors,
		"secondary_errors": secondary_errors
	}

func _validate_level3(password: String) -> Dictionary:
	var primary_errors = []
	var secondary_errors = []
	
	# Primary rules for Level 3 (all rules)
	if date_of_birth.size() > 0:
		var dob_pattern = "(" + String(",").join(date_of_birth).replace(",", "|") + ")"
		if _rule_breach_regex(password, "^(?!.*" + dob_pattern + ").*$"):
			primary_errors.append("prule1")
	
	if password.length() < 8:
		primary_errors.append("prule2")
	
	# Check usernames
	var username_pattern = ""
	for username in usernames:
		if username_pattern != "":
			username_pattern += "|"
		username_pattern += username
	
	if username_pattern != "" and _rule_breach_regex(password, "^(?!.*" + username_pattern + ").*$"):
		primary_errors.append("prule3")
	
	if _rule_breach_regex(password, "^(?=.*[A-Z]).*$"):
		primary_errors.append("prule4")
	
	if _rule_breach_regex(password, "^(?=.*[a-z]).*$"):
		primary_errors.append("prule5")
	
	if _rule_breach_regex(password, "^(?=.*[0-9]).*$"):
		primary_errors.append("prule6")
	
	if _rule_breach_regex(password, "^(?=.*[@#€&*:;!?_\\-\\$%]).*$"):
		primary_errors.append("prule7")
	
	# Secondary rules for Level 3 (all rules)
	if _rule_breach_regex(password, "^(?!.*(\\d)\\1).*$"):
		secondary_errors.append("srule1")
		visible_sec_rules["srule1"] = true
	
	if _rule_breach_regex(password, "^(?!.*(01|12|23|34|45|56|67|78|89|98|87|76|65|54|43|32|21|10)).*$"):
		secondary_errors.append("srule2")
		visible_sec_rules["srule2"] = true
	
	if _rule_breach_regex(password, "^(?!.*([a-zA-Z])\\1).*$"):
		secondary_errors.append("srule3")
		visible_sec_rules["srule3"] = true
	
	if _rule_breach_regex(password, "^(?!.*(ab|bc|cd|de|ef|fg|gh|hi|ij|jk|kl|lm|mn|no|op|pq|qr|rs|st|tu|uv|vw|wx|xy|yz)).*$", true):
		secondary_errors.append("srule4")
		visible_sec_rules["srule4"] = true
	
	if _rule_breach_regex(password, "^(?!.*\\d{3}).*$"):
		secondary_errors.append("srule5")
		visible_sec_rules["srule5"] = true
	
	if _rule_breach_regex(password, "^(?!.*([@#€&*:;!?_\\-\\$%])\\1\\1).*$"):
		secondary_errors.append("srule6")
		visible_sec_rules["srule6"] = true
	
	return {
		"primary_errors": primary_errors,
		"secondary_errors": secondary_errors
	}

func _rule_breach_regex(password: String, pattern: String, case_insensitive: bool = false) -> bool:
	var regex := RegEx.new()
	
	# Add case-insensitive flag if needed
	if case_insensitive:
		pattern = "(?i)" + pattern
	
	if regex.compile(pattern) != OK:
		print("Regex compilation failed for pattern: ", pattern)
		return true
	
	return regex.search(password) == null

# Helper function to get visible secondary rules for display
func get_visible_secondary_rules() -> Array:
	var visible = []
	for key in visible_sec_rules.keys():
		if visible_sec_rules[key]:
			visible.append(key)
	return visible

# Helper to manually set a secondary rule as discovered (for loading saved games)
func set_secondary_rule_visible(rule_key: String, visible: bool):
	if rule_key in visible_sec_rules:
		visible_sec_rules[rule_key] = visible
