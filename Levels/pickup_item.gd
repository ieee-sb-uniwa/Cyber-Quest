extends Node2D

const unpicked_z_index = 1
const max_items_picked_up = 3
var picked : bool = false
var item_number : int = 0
var get_player = "../../Player"
var get_player_marker = "../../Player/Marker"

func _input(event):
	if Input.is_action_just_pressed("drop"):
		print("press q")
		var bodies = $InteractionArea.get_overlapping_bodies()
		for body in bodies:
			print("detected a body")
			if body.name == "Player" and picked == true:
				picked = false
				Global.items_picked_up -= 1
				self.z_index = unpicked_z_index + item_number
				item_number = 0
				print("dropped")
	if Input.is_action_just_pressed("ui_accept"):
		print("press space")
		var bodies = $InteractionArea.get_overlapping_bodies()
		for body in bodies:
			print("detected a body")
			if body.name == "Player" and Global.items_picked_up < max_items_picked_up and picked == false:
				picked = true
				Global.items_picked_up += 1
				item_number = Global.items_picked_up
				print("picked up")
				self.z_index = get_node(get_player).z_index + item_number

func _process(delta):
	if picked == true:
		self.position = get_node(get_player_marker+str(item_number)).global_position
	if (Input.get_action_strength("move_up") > Input.get_action_strength("move_down")
	and Input.get_action_strength("move_right") == 0 and Input.get_action_strength("move_left") == 0
	and picked == true and get_node(get_player).velocity != Vector2.ZERO):
		self.z_index = get_node(get_player).z_index + item_number
	elif (get_node(get_player).velocity != Vector2.ZERO) and picked == true:
		self.z_index = get_node(get_player).z_index + item_number - max_items_picked_up
