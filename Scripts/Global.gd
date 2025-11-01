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
var passblocks_in_level : Array = [] # List of passblocks in level to ensure unique ids

# General Password Rules Properties
var dob1 := "07/02/2008"
var dob2 := "03/12/2008"
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

# Player1 profile
var player_name_1: String = ""
var birthdate_1: String = ""

# Player2 profile
var player_name_2: String = ""
var birthdate_2: String = ""

# Level global variables
var isTutorial: bool = true
var players: Array[CharacterBody2D] = []
enum MOVE_ORIENTATION {LEFT, RIGHT, UP, DOWN, EMPTY}
enum INTERACTION_STATUS{AVAILABLE, INTERACTED, OCCUPIED, EMPTY}
var terminal_unlocked: bool = false
var can_pause_game: bool = true
var saveData :SaveData

func _ready():
	saveData = SaveData.new()


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
		
func change_level() -> void:
	PlayerData.level+=1
	print(PlayerData.level)
	saveData.save_game()
	
func load_game() -> void:
	var canLoad = saveData.load_game()
	if canLoad:
		print("go to loaded level")
	else:
		print("no save available")
