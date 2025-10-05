extends Node

# Player1 profile
var player_name_1: String = ""
var birthdate_1: String = ""

# Player2 profile
var player_name_2: String = ""
var birthdate_2: String = ""

var level: int = 0

var inventory: Dictionary = { 
#	1: "res://assets/inventory/item1.png", 
#   2: "res://assets/inventory/item2.png" 
} 

func get_curr_inventory() -> Dictionary:
	var curr_dictionary :Dictionary = {}
	if level == 0:
		return curr_dictionary
	for i in range(level):
		if i <= inventory.size():
			curr_dictionary[i] = inventory[i]
	return curr_dictionary
	
