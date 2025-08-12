extends Node2D
@onready var curr_player = null
@onready var label = $Label

# holds all objects the player can currently interact with.
var active_areas = []
var can_interact = true

# Getter method to access the label
func get_label() -> Label:
	return label
	
func register_area(area: InteractionArea, body: Node2D):
	active_areas.push_back(area) # adds area to available areas
	curr_player = body
	show_action_label(area) # prints area label

func unregister_area(area: InteractionArea):
	var index = active_areas.find(area) 
	if index != -1:
		active_areas.remove_at(index)
		label.hide() # hide label when you exit area

func show_action_label(area: InteractionArea):
	if Global.isTutorial: # If we in tutorial state
		label.text = "Press " + Global.get_player_interact_button(curr_player) +" to " + area.action_name
		label.global_position = area.global_position
		label.global_position.y -= 36
		label.global_position.x -= label.size.x / 2
		label.show()
