extends Node

signal passblock_count_changed()
signal force_respawn(player)

# PassBlock global variables
var passblock_count : int = 0
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
var isTutorial: bool
var canExitLevel: bool = false
var can_pause_game: bool = true

var lobby_doors_open: Array
var terminal_unlocked: bool = false

# Keyboard mode for the current terminal
var terminal_ui_part := {
	"num": false,
	"letters": false,
	"symbols": false,
}

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
var usernames : Array = []
var pri_rules := {
	"prule1": {"text": "Μην βάλεις την ημερομηνία γέννησής σου.", "visible": false, "regex": ""}, 
	"prule2": {"text": "Μήκος κωδικού τουλάχιστον 8 ψηφία.", "visible": false, "regex": "^.{8,}$"},
	"prule3": {"text": "Μην βάλεις το όνομά σου.", "visible": false, "regex": ""},
	"prule4": {"text": "Βάλε τουλάχιστον ένα κεφαλαίο γράμμα.", "visible": false, "regex": "^(?=.*[A-Z]).*$"},
	"prule5": {"text": "Βάλε τουλάχιστον ένα πεζό γράμμα.", "visible": false, "regex": "^(?=.*[a-z]).*$"},
	"prule6": {"text": "Βάλε τουλάχιστον έναν αριθμό.", "visible": false, "regex": "^(?=.*[0-9]).*$"},
	"prule7": {"text": "Βάλε τουλάχιστον ένα ειδικό σύμβολο.", "visible": false, "regex": "^(?=.*[@#€&*:;!?_\\-\\$%]).*$"},
}
var sec_rules := {
	"srule1": {"text": "2 συνεχόμενα νούμερα να μην είναι ίδια.", "visible": false, "regex": "^(?!.*(\\d)\\1).*$"},
	"srule2": {"text": "2 συνεχόμενα νούμερα να μην είναι σε σειρά ή αντίστροφα.", "visible": false, "regex": "^(?!.*(01|12|23|34|45|56|67|78|89|98|87|76|65|54|43|32|21|10)).*$"},
	"srule3": {"text": "2 συνεχόμενα γράμματα να μην είναι ίδια.", "visible": false, "regex": "^(?!.*([a-zA-Z])\\1).*$"},
	"srule4": {"text": "2 συνεχόμενα γράμματα να μην είναι σε σειρά.", "visible": false, "regex": "^(?!.*(ab|bc|cd|de|ef|fg|gh|hi|ij|jk|kl|lm|mn|no|op|pq|qr|rs|st|tu|uv|vw|wx|xy|yz|AB|BC|CD|DE|EF|FG|GH|HI|IJ|JK|KL|LM|MN|NO|OP|PQ|QR|RS|ST|TU|UV|VW|WX|XY|YZ)).*$"},
	"srule5": {"text": "Να μην υπάρχουν 3 συνεχόμενοι αριθμοί.", "visible": false, "regex": "^(?!.*\\d{3}).*$"},
	"srule6": {"text": "Να μην υπάρχουν 3 συνεχόμενα ειδικά σύμβολα.", "visible": false, "regex": "^(?!.*([@#€&*:;!?_\\-\\$%])\\1\\1).*$"},
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
	passblock_count = 0;
	passblock_count_changed.emit()
	Hide_status = 1
	terminal_unlocked = false
	canExitLevel = false

func before_scene_change() -> void:
	# Clear runtime references that should not persist across scenes
	players.clear()
	passblocks_in_level.clear()
	dropped_passblocks.clear()
	player_entered_spawn = [false, false]
	# Reset inventory GUI
	if inventory_gui:
		inventory_gui.clear_inventory()
	# Reset SpawnManager if available to avoid stale player refs
	inventory_gui = null
	if typeof(SpawnManager) != TYPE_NIL:
		SpawnManager.reset()

func change_scene(target_scene: String, target_index: int) -> void:
	before_scene_change()
	reset_variables()
	get_tree().call_deferred("change_scene_to_file", target_scene)
	PlayerData.level = target_index
	save_game()

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
	# print("Current Inv Slot: ", PlayerData.inv_slot, " Required Slot: ", required_slot)
	return PlayerData.inv_slot >= required_slot

## PassBlock Functions
func add_passblock(passblock: Node) -> void:
	dropped_passblocks.append(passblock)
	# print("Passblocks in level: ", passblocks_in_level.size())
	if dropped_passblocks.size() == passblocks_in_level.size():
		# print("All passblocks collected!")
		canExitLevel = true
		update_inv()

var players_to_respawn: Array = []
## Respawn player if fallen out of bridge or fallen (general)
func request_respawn(player):
	if players_to_respawn.has(player):
		return
	players_to_respawn.append(player)
	force_respawn.emit(player)

## Remove "dead" player from players to be respawned
func clear_players():
	players_to_respawn.clear()

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

func on_new_game(player_names: Array, birthdates: Array) -> void:
	PlayerData.player_name_1 = player_names[0]
	PlayerData.birthdate_1 = birthdates[0]
	PlayerData.player_name_2 = player_names[1]
	PlayerData.birthdate_2 = birthdates[1]
	user1 = player_names[0]
	PlayerData.inv_slot = 0
	PlayerData.level = 11
	isTutorial = true
	lobby_doors_open = [true, false, true]
	
## Save and Load Functions
func load_game() -> void:
	var canLoad = saveData.load_game()
	if canLoad:
		dob1 = PlayerData.birthdate_1
		dob2 = PlayerData.birthdate_2
		user1 = PlayerData.player_name_1
		user2 = PlayerData.player_name_2
		#? PlayerData.level and PlayerData.inv_slot are loaded/used directly
	else:
		print("no save available")

func save_game() -> void:
	saveData.save_game()
	
func get_visible_pri_rules_text() -> String:
	var text = ""
	if terminal_ui_part.num:
		for i in range(1, 3):
			text += pri_rules["prule" + str(i)]["text"] + "\n"
	elif terminal_ui_part.letters:
		for i in range(3, 7):
			text += pri_rules["prule" + str(i)]["text"] + "\n"
	elif terminal_ui_part.symbols:
		text += pri_rules["prule7"]["text"]
	return text
