extends Node2D

@onready var player = null
@onready var label = $Label

var active_areas = [] # holds all objects the player can currently interact with.
var can_interact = true

# Getter method to access the label
func get_label() -> Label:
	return label
	

func register_area(area: InteractionArea):
	active_areas.push_back(area) # adds area to available areas
	show_action_label(area) # prints area label

func unregister_area(area: InteractionArea):
	var index = active_areas.find(area) 
	if index != -1:
		active_areas.remove_at(index)
		label.hide() # hide label when you exit area

func show_action_label(area):
	if Global.isTutorial: # If we in tutorial state
		label.text = "Press" + area.action_key + "to " + area.action_name
		label.global_position = area.global_position
		label.global_position.y -= 36
		label.global_position.x -= label.size.x / 2
		label.show()

#func _sort_by_distance_to_player(area1, area2):
	#player = get_tree().get_first_node_in_group("player")
	#var area1_to_player = player.global_position.distance_to(area1.global_position)
	#var area2_to_player = player.global_position.distance_to(area2.global_position)
	#return area1_to_player < area2_to_player
