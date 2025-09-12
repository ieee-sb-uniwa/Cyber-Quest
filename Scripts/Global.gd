extends Node

# PassBlock global variables
var blocks_picked : int = 0
var max_player_items : int = 2
var max_passblocks : int = max_player_items * 2
var player_blocks: Array = [0, 0]  
var dropped_passblocks: Array = []
# Hide/Show global variables
var Hide_status: int = 1
# Player global variables
var move_speed : float = 150
# Level global variables
var isTutorial: bool = true
enum MOVE_ORIENTATION {LEFT, RIGHT, UP, DOWN, EMPTY}
enum INTERACTION_STATUS{AVAILABLE, INTERACTED, OCCUPIED, EMPTY}

func reset_variables() -> void:
	blocks_picked = 0
	player_blocks = [0, 0]
	dropped_passblocks.clear()
	Hide_status = 1
	isTutorial = true

func player_interacts(interact_button: String, player_group: String, player: Node) -> bool:
	return Input.is_action_just_pressed(interact_button) and player.is_in_group(player_group)

func get_player_interact_button(body: Node2D) -> String:
	if body.is_in_group("MainPlayer"):
		return "[E]"
	elif body.is_in_group("SecondPlayer"):
		return "[.]"
	else:
		return ""