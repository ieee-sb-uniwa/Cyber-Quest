extends Node

# PassBlock global variables
var blocks_picked : int = 0
var max_player_items : int = 2
var player_blocks: Array = [0, 0]  
var dropped_passblocks: Array = []
var passblocks_in_level : Array = [] # List of passblocks in level to ensure unique ids

# Player global variables
var player_entered_spawn = [false, false]
var players: Array[CharacterBody2D] = []
var Hide_status: int = 1
var move_speed : float = 150

# Level global variables
var isTutorial: bool = true
var canExitLevel: bool = false
var can_pause_game: bool = true

var lobby_doors_open: Array = [true, false, false] # (storage, comms, engineroom)
var terminal_unlocked: bool = false

enum MOVE_ORIENTATION {LEFT, RIGHT, UP, DOWN, EMPTY}
enum INTERACTION_STATUS{AVAILABLE, INTERACTED, OCCUPIED, EMPTY}

## References
var saveData :SaveData
var inventory_gui : Control

# General Password Rules Properties
var dob1 := "" # Player date of birth 1
var dob2 := "" # Player date of birth 2
var user1 := "" # Player name 1
var user2 := "" # Player name 2
var date_of_birth : Array = []
var pri_rules := {
	"prule1": "Μην βάλεις την ημερομηνία γέννησής σου.",
	"prule2": "Μήκος κωδικού τουλάχιστον 8 ψηφία.",
	"prule3": "Μην βάλεις το όνομά σου.",
	"prule4": "Βάλε τουλάχιστον ένα κεφαλαίο γράμμα.",
	"prule5": "Βάλε τουλάχιστον ένα πεζό γράμμα.",
	"prule6": "Βάλε τουλάχιστον έναν αριθμό.",
	"prule7": "Βάλε τουλάχιστον ένα ειδικό σύμβολο."
}
var sec_rules := {
	"srule1": "2 συνεχόμενα νούμερα να μην είναι ίδια.",
	"srule2": "2 συνεχόμενα νούμερα να μην είναι σε σειρά ή αντίστροφα.",
	"srule3": "2 συνεχόμενα γράμματα να μην είναι ίδια.",
	"srule4": "2 συνεχόμενα γράμματα να μην είναι σε σειρά ή αντίστροφα.",
	"srule5": "Να μην υπάρχουν 3 συνεχόμενα ψηφία.",
	"srule6": "Να μην υπάρχουν 3 συνεχόμενα ειδικά σύμβολα."
}
var visible_pri_rules := {
	"prule1": false,
	"prule2": false,
	"prule3": false,
	"prule4": false,
	"prule5": false,
	"prule6": false,
	"prule7": false
}

var visible_sec_rules := {
	"srule1": false,
	"srule2": false,
	"srule3": false,
	"srule4": false,
	"srule5": false,
	"srule6": false
}

func _ready():
	saveData = SaveData.new()
	load_game()

func _exit_tree():
	if saveData:
		saveData.free()
		saveData = null

## Reset Functions
func reset_variables() -> void:
	blocks_picked = 0
	player_blocks = [0, 0]
	dropped_passblocks.clear()
	Hide_status = 1
	terminal_unlocked = false
	canExitLevel = false

func before_scene_change() -> void:
	# Clear runtime references that should not persist across scenes
	players.clear()
	passblocks_in_level.clear()
	dropped_passblocks.clear()
	player_entered_spawn = [false, false]
	# Reset SpawnManager if available to avoid stale player refs
	if typeof(SpawnManager) != TYPE_NIL:
		SpawnManager.reset()

func can_access_terminal() -> bool:
	# Check if current level matches the required inventory slot
	var required_slot = 0
	match PlayerData.level:
		11:
			required_slot = 1
		12:
			required_slot = 3
		15:
			required_slot = 4
	print("Current Inv Slot: ", PlayerData.inv_slot, " Required Slot: ", required_slot)
	return PlayerData.inv_slot >= required_slot

## PassBlock Functions
func add_passblock(passblock: Node) -> void:
	dropped_passblocks.append(passblock)
	# print("Passblocks in level: ", passblocks_in_level.size())
	if dropped_passblocks.size() == passblocks_in_level.size():
		# print("All passblocks collected!")
		canExitLevel = true
		update_inv()

func update_inv() -> void:
	passblocks_in_level.clear()
	PlayerData.inv_slot += 1
	if inventory_gui:
		inventory_gui.unlock_inventory_for_level(PlayerData.inv_slot)

## Interaction Functions
func player_interacts(interact_button: String, player_group: String, player: Node) -> bool:
	return Input.is_action_just_pressed(interact_button) and player.is_in_group(player_group)

func get_player_interact_button(body: Node2D) -> String:
	if body.is_in_group("MainPlayer"):
		return "[E]"
	elif body.is_in_group("SecondPlayer"):
		return "[.]"
	else:
		return ""
	
## Save and Load Functions
func load_game() -> void:
	var canLoad = saveData.load_game()
	if canLoad:
		dob1 = PlayerData.birthdate_1
		dob2 = PlayerData.birthdate_2
		user1 = PlayerData.player_name_1
		user2 = PlayerData.player_name_2
		# PlayerData.level and PlayerData.inv_slot are loaded directly
	else:
		print("no save available")

func save_game() -> void:
	saveData.save_game()