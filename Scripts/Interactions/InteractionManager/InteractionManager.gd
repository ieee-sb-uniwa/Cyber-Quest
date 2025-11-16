extends Node2D

# Defensive initialization: assign in _ready to avoid errors if node graph changes
var curr_player: Node2D = null
var label: Label = null

# holds all objects the player can currently interact with.
var active_areas: Array = []
var can_interact: bool = true

# Getter method to access the label (returns null if not available)
func get_label() -> Label:
	if label and is_instance_valid(label):
		return label
	return null

func _ready() -> void:
	if has_node("Label"):
		label = $Label
	
func register_area(area: InteractionArea, body: Node2D) -> void:
	active_areas.push_back(area) # adds area to available areas
	curr_player = body
	# Only show label if it's available and this manager can interact
	if can_interact and get_label():
		show_action_label(area) # prints area label

func unregister_area(area: InteractionArea) -> void:
	var index = active_areas.find(area)
	if index != -1:
		active_areas.remove_at(index)
		var l = get_label()
		if l:
			l.hide() # hide label when you exit area

func show_action_label(area: InteractionArea) -> void:
	var l = get_label()
	if not l:
		return
	if Global.isTutorial: # If we in tutorial state
		# Defensive checks for curr_player
		var btn = ""
		if curr_player and is_instance_valid(curr_player):
			btn = Global.get_player_interact_button(curr_player)
		l.text = "Πάτα " + btn + " για να " + area.action_name
		l.global_position = area.global_position
		l.global_position.y -= 36
		# Guard label size access
		if l.has_method("get_size"):
			l.global_position.x -= l.size.x / 2
		else:
			# best-effort: try to access size property if present
			if "size" in l:
				l.global_position.x -= l.size.x / 2
		l.show()
