extends StaticBody2D

var unpicked_z_index : int
const max_items_picked_up = 3
var picked = false
var item_number : int = 0
var label_shown = false  
var block_id 
var pickupPressed = true
@onready var block_sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func get_player():
	return get_node("../../Player")

func get_player_marker():
	return get_node("../../Player/Marker" + str(item_number))

#func _input(_event):
	#var bodies = $InteractionArea.get_overlapping_bodies()
	## only check input if there is a body inside area 
	#if bodies.size() == 0: 
		#return
	#if Input.is_action_just_pressed("pickup"):	
		#if Global.items_picked_up < max_items_picked_up:
			#for body in bodies:
				#if body.name == "Player":
					#print("picked up")
					#picked = true
					#item_number = Global.items_picked_up + 1
					#Global.items_picked_up += 1
					#self.z_index = get_player().z_index + item_number
					#disable_collision(true)
					#show_label()
		#else:
			#for body in bodies:
				#if body.name == "Player":
					#print("dropped")
					#picked = false
					#item_number = 0
					#Global.items_picked_up = 0
					#self.z_index = unpicked_z_index + item_number
					#disable_collision(false)
					#$InteractionArea.get_label().hide()
		#print("-------")
		#print("Global" + str(Global.items_picked_up))
		#print("Local" + str(item_number))
		#print("-------")
					
func _input(_event):
	var bodies = $InteractionArea.get_overlapping_bodies()
	# only check input if there is a body inside area 
	if bodies.size() == 0: 
		return
	if Input.is_action_just_pressed("drop"):
		for body in bodies:
			if body.name == "Player" and picked == true:
				picked = false
				Global.items_picked_up -= 1
				self.z_index = unpicked_z_index + item_number
				print(self.z_index)
				item_number = 0
				print("dropped")
				disable_collision(false)
				$InteractionArea.get_label().hide()
	if Input.is_action_just_pressed("ui_accept") and Global.items_picked_up < max_items_picked_up:
		for body in bodies:
			if body.name == "Player" and picked == false:
				show_label()
				picked = true
				Global.items_picked_up += 1
				item_number = Global.items_picked_up
				print("picked up")
				self.z_index = get_player().z_index + item_number
				print(self.z_index)
				disable_collision(true)

func _process(_delta):
	# If it is picked up 
	if picked == true:
		self.position = get_player_marker().global_position 
		if get_player().velocity != Vector2.ZERO:
			# show the block on top of player
			if (player_moving_up()):
				self.z_index = get_player().z_index + item_number 
			# show the block behind the player
			else:
				self.z_index = get_player().z_index + item_number - max_items_picked_up 
				
	# Check if the player moved after the label was shown and then hide it
	hide_label()

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
	
func _ready():
	unpicked_z_index = self.z_index # Initialize default z index
	# Initialize block number at initialiazation
	randomize()
	block_id = rand_num(0,9)
	print("Block id: " + str(block_id))
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
		$InteractionArea.set_label("Press [Space] to drop.")
		label_shown = true 

# Set collision
func disable_collision(flag: bool):
	collision_shape.disabled = flag 
