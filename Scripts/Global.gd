extends Node

# PassBlock global variables
var blocks_picked : int = 0
var max_player_items : int = 2
var player_blocks: Array = [0, 0]  
var dropped_passblocks: Array = []
var player_entered_spawn = [false, false]
var Hide_status: int = 1
# Player global variables
var move_speed : float = 150

# Level global variables
var isTutorial: bool = true
var players: Array[CharacterBody2D] = []
enum MOVE_ORIENTATION {LEFT, RIGHT, UP, DOWN, EMPTY}
enum INTERACTION_STATUS{AVAILABLE, INTERACTED, OCCUPIED, EMPTY}
var terminal_unlocked: bool = false
var can_pause_game: bool = true

var lobby_doors_open: Array = [true, false, false] # First door is open by default (storage, comms, engineroom)
var current_level: int = 0

func reset_variables() -> void:
	blocks_picked = 0
	player_blocks = [0, 0]
	dropped_passblocks.clear()
	Hide_status = 1
	terminal_unlocked = false

func can_access_terminal() -> bool:
	return dropped_passblocks.size() == max_player_items * 2 # 4 for room 1 -> this can be changed later for more rooms

func player_interacts(interact_button: String, player_group: String, player: Node) -> bool:
	return Input.is_action_just_pressed(interact_button) and player.is_in_group(player_group)

func get_player_interact_button(body: Node2D) -> String:
	if body.is_in_group("MainPlayer"):
		return "[E]"
	elif body.is_in_group("SecondPlayer"):
		return "[.]"
	else:
		return ""
