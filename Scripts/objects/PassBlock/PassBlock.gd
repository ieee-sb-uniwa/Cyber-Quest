extends StaticBody2D

@onready var block_sprite: Sprite2D = $Sprite2D
@onready var passArea = $InteractionArea
# Flag to determine what type of block to spawn
@export var is_num: bool = true
@export var is_upper: bool = false
@export var is_lower: bool = false
@export var is_symbol: bool = false

var unpicked_z_index : int
var picked = false
var block_number : int = 0
var block_id
	
func set_collision(flag: bool):
	print("Setting collision to: ", flag)
	$CollisionShape2D.set_deferred("disabled", flag)

func set_interaction_area(flag: bool):
	passArea.call_deferred("set", "monitoring", flag)
	passArea.call_deferred("set", "monitorable", flag)

func interaction_area_is_disabled() -> bool:
	var area = passArea
	var shape = area.get_node("CollisionShape2D")
	return !area.monitoring and !area.monitorable and shape.disabled

# ---- Drop/Pick block ----
func drop_block(body: Node2D):
	picked = false
	Global.blocks_picked -= 1
	self.z_index = unpicked_z_index + block_number
	set_interaction_area(true)
	if body.is_in_group("MainPlayer"):
		Global.player_blocks[0] -= 1
	elif body.is_in_group("SecondPlayer"):
		Global.player_blocks[1] -= 1
	
func pick_block(body: Node2D):
	set_interaction_area(false)
	picked = true
	Global.blocks_picked += 1
	if body.is_in_group("MainPlayer"):
		Global.player_blocks[0] += 1
	elif body.is_in_group("SecondPlayer"):
		Global.player_blocks[1] += 1
	if body.has_method("add_item_to_holder"):
		body.add_item_to_holder(self)
	Global.add_passblock(self)

# ------- "Interact" button logic ------- 				
func _input(_event):
	# Check if disabled so not to repeat pickup logic for picked up items
	if interaction_area_is_disabled() or !passArea.monitoring:
		return
	
	# Check if this is the closest interaction area
	var closest_area = InteractionManager.get_closest_area()
	if closest_area != passArea:
		return
		
	var bodies = passArea.get_overlapping_bodies()
	# Only check input if there is a body inside area
	if bodies.size() == 0: 
		return
	# Pickup logic for Global.max_player_items
	for body in bodies:
		if body.has_method("player") and picked == false:
			if Global.player_interacts("Interact_p1", "MainPlayer", body) or Global.player_interacts("Interact_p2", "SecondPlayer", body):
				# print(Global.max_player_items)
				if Global.player_blocks[0] >= Global.max_player_items and body.is_in_group("MainPlayer"):
					print("Max items for player 1 reached")
					return
				elif Global.player_blocks[1] >= Global.max_player_items and body.is_in_group("SecondPlayer"):
					print("Max items for player 2 reached")
					return
				pick_block(body)
				block_number = Global.blocks_picked	

# ----- Initialiazation -----
func _ready():
	unpicked_z_index = self.z_index 
	passArea.is_pickup_item = true  # PassBlocks require inventory space
	set_block_sprite()

func set_block_sprite():
	randomize()

	block_id = set_block_based_on_type()
	# Best-effort uniqueness without risking infinite loops
	var max_unique := 28
	if is_num:
		max_unique = 4
	elif is_upper or is_lower or is_symbol:
		max_unique = 8

	var attempts := 0
	# Try a limited number of times to find a non-duplicate id
	while (block_id in Global.passblocks_in_level) and attempts < max_unique * 2:
		block_id = set_block_based_on_type()
		attempts += 1

	# Add to global list of blocks in level
	Global.passblocks_in_level.append(block_id)
	block_sprite.set_frame(block_id)

func set_block_based_on_type():
	var num_len = 4
	var letr_symb_len = 8
	var idx = 0
	var offset = 0
	if is_num:
		idx = randi_range(0, num_len - 1)
	elif is_lower:
		offset = num_len
		idx = randi_range(0, letr_symb_len - 1)
	elif is_upper:
		offset = num_len + letr_symb_len
		idx = randi_range(0, letr_symb_len - 1)
	elif is_symbol:
		offset = num_len + 2 * letr_symb_len
		idx = randi_range(0, letr_symb_len - 1)
	return offset + idx
