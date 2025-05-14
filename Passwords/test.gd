extends Node

@onready var pass_nodes=[
	$Password/Pass1,
	$Password/Pass2,
	$Password/Pass3,
	$Password/Pass4,
	$Password/Pass5,
	$Password/Pass6,
	$Password/Pass7,
	$Password/Pass8 ]

@onready var confirm_button = $Confirm

@onready var rule_label_1 = $Rules/Rule1
@onready var rule_label_2 = $Rules/Rule2
@onready var rule_label_3 = $Rules/Rule3


func _ready():
	update_confirm_button()


func update_confirm_button():
	var count = 0
	for pass_node in pass_nodes:
		#print(pass_node.name, "texture is", pass_node.texture)
		if pass_node.texture != null:
			count += 1
	confirm_button.disabled = count < pass_nodes.size()
	#print("count:", count, ", confirm button disabled:", confirm_button.disabled)

func rule1_breach(password):
	for i in range(password.size() - 1):
		if password[i] == password[i + 1]:
			return true
	return false

func rule2_breach(password):
	for i in range(password.size() - 1):
		if password[i] + 1 == password[i + 1] or password[i] - 1 == password[i + 1]:
			return true
	return false

var date_of_birth = "2008"

func rule3_breach(password):
	var password_str = ""
	for digit in password:
		password_str += str(digit)
		if(date_of_birth in password_str):
			return true
	return false

func update_rule_feedback():
	var password = []
	for node in pass_nodes:
		if node.texture == null:
			reset_rules()
			return
		# Extract the number from texture filename (e.g., "3.png" → 3)
		var tex_name = node.texture.resource_path.get_file().get_basename()
		var number = int(tex_name)
		password.append(number)

	var rule1 = rule1_breach(password)
	var rule2 = rule2_breach(password)
	var rule3 = rule3_breach(password)
	
	rule_label_2.bbcode_enabled = true

	rule_label_1.text = "[color=green]✔ 1. No two numbers are the same[/color]" if not rule1 else "[color=red]✘ 1. No two numbers are the same[/color]"

	rule_label_2.text = "[color=green]✔ 2. No two numbers in ascending or descending order[/color]" if not rule2 else "[color=red]✘ 2. No two numbers in ascending or descending order[/color]"

	rule_label_3.text = "[color=green]✔ 3. Do not use Date of Birth[/color]" if not rule3 else "[color=red]✘ 3. Do not use Date of Birth[/color]"

func reset_rules():
	rule_label_1.text = "1. No two numbers are the same"
	rule_label_2.text = "2. No two numbers in ascending or descending order"
	rule_label_3.text = "3. Do not use Date of Birth"

func _on_confirm_pressed() -> void:
	update_rule_feedback()
