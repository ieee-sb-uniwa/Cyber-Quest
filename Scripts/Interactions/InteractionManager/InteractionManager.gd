extends Node2D

# Defensive initialization: assign in _ready to avoid errors if node graph changes
var curr_player: Node2D = null
var label: Label = null

# holds all objects the player can currently interact with.
var active_areas: Array = []
var can_interact: bool = true

func _ready():
	label = $Label

# Getter method to access the label (returns null if not available)
func get_label() -> Label:
	return label

func _process(_delta):
	# Always update label to handle both showing closest and hiding when empty
	update_closest_label()

# Get the closest interaction area to the current player
func get_closest_area() -> InteractionArea:
	if active_areas.is_empty() or curr_player == null:
		return null
	
	var closest_area: InteractionArea = null
	var closest_distance: float = INF
	
	for area in active_areas:
		if area == null:
			continue
		var distance = curr_player.global_position.distance_to(area.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_area = area
	
	return closest_area
	
func register_area(area: InteractionArea, body: Node2D):
	active_areas.push_back(area) # adds area to available areas
	curr_player = body
	# Don't need to update label here, _process will handle it

func unregister_area(area: InteractionArea) -> void:
	var index = active_areas.find(area)
	if index != -1:
		active_areas.remove_at(index)
		# Immediately update label when unregistering
		update_closest_label()

func update_closest_label():
	var closest = get_closest_area()
	if closest:
		show_action_label(closest)
	else:
		label.hide()

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
