extends StaticBody2D

const unpicked_z_index = 1
const max_items_picked_up = 3
var picked = false
var item_number : int = 0
var label_shown = false  
var block_id 
@onready var block_sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func get_player():
	return get_node("../../Player")

func get_player_marker():
	return get_node("../../Player/Marker" + str(item_number))

func _input(_event):
	var bodies = $InteractionArea.get_overlapping_bodies()
	if bodies.size() == 0: # only check input if there is a body inside area 
		return
	if Input.is_action_just_pressed("drop"):
		print("press q")
		for body in bodies:
			print("detected a body")
			if body.name == "Player" and picked == true:
				picked = false
				Global.items_picked_up -= 1
				self.z_index = unpicked_z_index + item_number
				item_number = 0
				print("dropped")
				disable_collision(false)
	if Input.is_action_just_pressed("ui_accept"):
		print("press space")
		show_label()
		for body in bodies:
			print("detected a body")
			if body.name == "Player" and Global.items_picked_up < max_items_picked_up and picked == false:
				picked = true
				Global.items_picked_up += 1
				item_number = Global.items_picked_up
				print("picked up")
				self.z_index = get_player().z_index + item_number
				disable_collision(true)

func _process(_delta):
	if picked == true:
		self.position = get_player_marker().global_position # If it is picked up 
	if (show_on_top()):
		self.z_index = get_player().z_index + item_number # show the block on top of player
	elif (get_player().velocity != Vector2.ZERO) and picked == true: 
		self.z_index = get_player().z_index + item_number - max_items_picked_up
	
	# Check if the player moved after the label was shown and then hide it
	hide_label()
	
func _ready():
	# Initialize block number at initialiazation
	randomize()
	block_id = rand_num(0,9)
	print(block_id)
	block_sprite.set_frame(block_id)  # depending on randon number assign frame (0-9)

### Random number 
func rand_num(a, b : int):
	return randi_range(a, b)

### Random letter -> give true for lowercase
func rand_letter(isLowercase: bool):
	if isLowercase:
		block_id = rand_num(97,122) 
		return char(97 + randi() % 26) # 'a' - 'z' (ASCII code 97-122)
	else:
		block_id = rand_num(65,90)
		return char(65 + randi() % 26) # 'A' - 'Z' (ASCII code 65-90)
	
func show_on_top():
	return (
		Input.get_action_strength("move_up") > Input.get_action_strength("move_down") 
		and Input.get_action_strength("move_right") == 0 
		and Input.get_action_strength("move_left") == 0 
		and picked == true 
		and get_player().velocity != Vector2.ZERO
)

func player_moved():
	return (
		Input.get_action_strength("move_up") > 0 or
		Input.get_action_strength("move_down") > 0 or
		Input.get_action_strength("move_left") > 0 or
		Input.get_action_strength("move_right") > 0
)

func hide_label():
	if label_shown and player_moved():
		$InteractionArea.get_label().hide()
		label_shown = false  
		
func show_label():
	if Global.isTutorial:
		$InteractionArea.set_label("Press [Q] to drop.")
		label_shown = true 

# Set collision
func disable_collision(flag: bool):
	collision_shape.disabled = flag 
