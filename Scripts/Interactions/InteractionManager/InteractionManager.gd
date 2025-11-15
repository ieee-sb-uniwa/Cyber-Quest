extends Node2D
@onready var curr_player = null
@onready var label = $Label

# holds all objects the player can currently interact with.
var active_areas = []
var can_interact = true

# Getter method to access the label
func get_label() -> Label:
	return label

func _process(_delta):
	# Update label position as player moves between overlapping areas
	if not active_areas.is_empty():
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

func unregister_area(area: InteractionArea):
	var index = active_areas.find(area) 
	if index != -1:
		active_areas.remove_at(index)
		# Don't need to update label here, _process will handle it

func update_closest_label():
	var closest = get_closest_area()
	if closest:
		show_action_label(closest)
	else:
		label.hide()

func show_action_label(area: InteractionArea):
	if Global.isTutorial: # If we in tutorial state
		label.text = "Πάτα " + Global.get_player_interact_button(curr_player) +" για να " + area.action_name
		label.global_position = area.global_position
		label.global_position.y -= 36
		label.global_position.x -= label.size.x / 2
		label.show()
