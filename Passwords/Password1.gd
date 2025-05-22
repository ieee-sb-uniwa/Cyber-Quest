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
var date_of_birth = "2008" #will take this from intro sequence eventually

func _ready():
	update_confirm_button()

func update_confirm_button(): #can confirm only ifall 8 blocks are placed
	var count = 0
	for pass_node in pass_nodes:
		if pass_node.texture != null:
			count += 1
	confirm_button.disabled = count < pass_nodes.size()
	
func rule_breach_regex(password, pattern): # if it matches it returns false
	var regex := RegEx.new()
	var error := regex.compile(pattern)
	if error != OK:
		print("Invalid regex pattern")
		return true
	return regex.search(password) == null

func update_rule_feedback():
	var password = ""
	for node in pass_nodes:
		if node.texture == null: # if block has been removed, rules reset
			reset_rules()
			return
		var tex_name = node.texture.resource_path.get_file().get_basename() # reads blocks
		password += str(int(tex_name)) # makes each block to password string
	
	var rule1 = rule_breach_regex(password, "^(?!.*(\\d)\\1)\\d{8}$")  # consequtive same numbers
	var rule2 = rule_breach_regex(password, "^(?!.*(01|12|23|34|45|56|67|78|89|98|87|76|65|54|43|32|21|10))\\d{8}$") # consequtive numbers in a row
	var rule3 = rule_breach_regex(password, "^(?!.*" + date_of_birth + ")\\d{8}$") # date of birth

	rule_label_1.text = "[color=green]✔ 1. Δύο αριθμοί στη σειρά δεν μπορούν να είναι ίδιοι[/color]" if not rule1 else "[color=red]✘ 1. Δύο αριθμοί στη σειρά δεν μπορούν να είναι ίδιοι[/color]"
	rule_label_2.text = "[color=green]✔ 2. Δύο αριθμοί στην σειρά δεν μπορούν να είναι ο ένας αμέσως επόμενος/προηγούμενος του άλλου[/color]" if not rule2 else "[color=red]✘ 2. Δύο αριθμοί στην σειρά δεν μπορούν να είναι ο ένας αμέσως επόμενος/προηγούμενος του άλλου[/color]"
	rule_label_3.text = "[color=green]✔ 3. Ο κωδικός δεν πρέπει να περιέχει την ημερομηνία γέννησής σου[/color]" if not rule3 else "[color=red]✘ 3. Ο κωδικός δεν πρέπει να περιέχει την ημερομηνία γέννησής σου[/color]"

func reset_rules():
	rule_label_1.text = "1. Δύο αριθμοί στη σειρά δεν μπορούν να είναι ίδιοι"
	rule_label_2.text = "2. Δύο αριθμοί στην σειρά δεν μπορούν να είναι ο ένας αμέσως επόμενος/προηγούμενος του άλλου"
	rule_label_3.text = "3. Ο κωδικός δεν πρέπει να περιέχει την ημερομηνία γέννησής σου"

func _on_confirm_pressed() -> void:
	update_rule_feedback()
