extends StaticBody2D
@onready var block_sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var passArea = $InteractionArea

var unpicked_z_index : int
const max_items = 3
var picked = false
var block_number : int = 0
var block_id

# ----- Helper functions -----
func get_player():
	return get_node("../../Player")

func get_player_marker():
	return get_node("../../Player/Marker" + str(block_number))
	
func set_collision(flag: bool):
	collision_shape.disabled = flag 

func disable_interaction_area():
	passArea.monitoring = false
	passArea.set_deferred("monitorable", false)
	passArea.get_node("CollisionShape2D").disabled = true

func interaction_area_is_disabled() -> bool:
	var area = passArea
	var shape = area.get_node("CollisionShape2D")
	return !area.monitoring and !area.monitorable and shape.disabled

func drop_block():
	picked = false
	set_collision(false)
	passArea.monitoring = true
	passArea.set_deferred("monitorable", true)
	passArea.get_node("CollisionShape2D").disabled = false
	remove_from_group("PickedPassBlocks") 

# ------- Pickup logic when pressed "Interact" button ------- 				
func _input(_event):
	# Check if disabled so not to repeat pickup logic for picked up items
	if interaction_area_is_disabled():
		return
	var bodies = passArea.get_overlapping_bodies()
	# Only check input if there is a body inside area
	if bodies.size() == 0: 
		return
	# Pickup logic for max_items
	if Input.is_action_just_pressed("Interact") and Global.blocks_picked < max_items:
		for body in bodies:
			if body.name == "Player" and picked == false:
				disable_interaction_area()
				set_collision(true)
				picked = true
				Global.blocks_picked += 1
				block_number = Global.blocks_picked
				self.z_index = get_player().z_index + block_number
				add_to_group("PickedPassBlocks") 
				
# ------ Z.index logic for pickup items while player is moving ------
func _process(_delta):
	# If it is picked up 
	if picked == true:
		self.position = get_player_marker().global_position 
		if get_player().velocity != Vector2.ZERO:
			# show the block on top of player
			if (player_moving_up()):
				self.z_index = get_player().z_index + block_number 
			# show the block behind the player
			else:
				self.z_index = get_player().z_index + block_number - max_items 

func player_moving_up():
	var up_strength = Input.get_action_strength("move_up")
	var down_strength = Input.get_action_strength("move_down")
	var left_strength = Input.get_action_strength("move_left")
	var right_strength = Input.get_action_strength("move_right")

	var vertical = up_strength - down_strength
	var horizontal = right_strength - left_strength

	# Check if moving mostly up or only up
	return vertical > 0 and (abs(vertical) > abs(horizontal) 
	or (up_strength > 0 and left_strength == 0 and right_strength == 0))

# ----- Initialiazation -----
func _ready():
	# Initialize default z index
	unpicked_z_index = self.z_index 
	# Initialize block number at initialiazation
	randomize()
	block_id = rand_num(0,9)
	print("Block id: " + str(block_id))
	# depending on randon number assign frame (0-9)
	block_sprite.set_frame(block_id)  

# Random number between a range (a,b)
func rand_num(a, b : int):
	return randi_range(a, b)

# Random letter -> give true for lowercase
func rand_letter(isLowercase: bool):
	if isLowercase:
		block_id = rand_num(97,122) 
		return char(97 + randi() % 26) # 'a' - 'z' (ASCII code 97-122)
	else:
		block_id = rand_num(65,90)
		return char(65 + randi() % 26) # 'A' - 'Z' (ASCII code 65-90)
