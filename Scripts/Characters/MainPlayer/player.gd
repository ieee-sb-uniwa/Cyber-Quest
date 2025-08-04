extends CharacterBody2D

@export var starting_direction : Vector2 = Vector2(0, 1)
@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")
@export var inventory: Inventory
@onready var hitbox = $Hitbox
@export var itemHodler : ItemHolder
@export var playerNum: int = 1
var move_speed = 5
var last_animation_look_location : Vector2 = Vector2(0,0)

## Pickup Item Functionality ##
var items_picked_up : int = 0
## ---- ##
@onready var P_sprite = $Sprite2D
@onready var P_collission = $CollisionShape2D

func _ready():
	update_animation_parameters(starting_direction)
	$Hitbox.body_entered.connect(_on_body_entered)
	itemHodler.set_player_index(self.z_index)
	move_speed = Global.move_speed
	var camera = get_tree().current_scene.get_node("CameraRoot/Camera2D")
	if camera.has_method("assign_player"):
		camera.assign_player(playerNum, self)

func _physics_process(_delta):	
	var input_direction = Vector2(get_horizontal_move(), get_vertical_move())
	update_animation_parameters(input_direction)
	
	velocity = input_direction.normalized() * move_speed
	pickup_item_positions()
	
	move_and_slide()
	pick_new_state()

func update_animation_parameters(move_input : Vector2):
	if(move_input == Vector2.ZERO):
		return
	var direction = move_input.normalized()
	var abs_x = abs(move_input.x)
	var abs_y = abs(move_input.y)
	var animation_look_location : Vector2 = Vector2(0,0)
	var move_orientation = Global.MOVE_ORIENTATION.EMPTY
	
	if abs_x > abs_y:
		animation_look_location = Vector2(direction.x, 0)
		move_orientation = Global.MOVE_ORIENTATION.RIGHT if direction.x > 0 else Global.MOVE_ORIENTATION.LEFT
	elif abs_y > abs_x:
		animation_look_location = Vector2(0, direction.y)
		move_orientation = Global.MOVE_ORIENTATION.DOWN if direction.y > 0 else Global.MOVE_ORIENTATION.UP
	else:
		# Equal (diagonal): return vertical OR use last pressed key logic
		if abs(last_animation_look_location.x) > 0.1 && abs(last_animation_look_location.y) < 0.1:
			print(str(abs_x)  + " : " + str(abs_y))
			animation_look_location = Vector2(0.2, direction.y)
			move_orientation = Global.MOVE_ORIENTATION.DOWN if direction.y > 0 else Global.MOVE_ORIENTATION.UP
		elif abs(last_animation_look_location.y) > 0.1 && abs(last_animation_look_location.x) < 0.1:
			animation_look_location = Vector2(direction.x, 0.2)
			print(animation_look_location)
			move_orientation = Global.MOVE_ORIENTATION.RIGHT if direction.x > 0 else Global.MOVE_ORIENTATION.LEFT
		else:
			return
	last_animation_look_location = animation_look_location
	animation_tree.set("parameters/Idle/blend_position", animation_look_location)
	animation_tree.set("parameters/Move/blend_position", animation_look_location)
	itemHodler.change_items_orientation(move_orientation)

func pick_new_state():
	if(velocity != Vector2.ZERO):
		state_machine.travel("Move")
	else:
		state_machine.travel("Idle")
func player(): #Is used to be identified by enemies
	pass
	
func get_move(move):
	return Input.get_action_strength(move)
	
func get_horizontal_move():
	return get_move("move_right_p" + str(playerNum)) - get_move("move_left_p" + str(playerNum))

func get_vertical_move():
	return get_move("move_down_p" + str(playerNum)) - get_move("move_up_p" + str(playerNum))
	
func add_item_to_holder(item : Node2D) -> void:
	itemHodler.add_item(item)
	
func get_all_items() -> Array[Node2D]:
	return itemHodler.get_all_items()

func clear_all_items() -> void:
	itemHodler.clear_all_items(self.global_position)
	
func pickup_item_positions():	
	# If no movement, don't do anything
	if (velocity == Vector2.ZERO):
		return
	# Hardcoded positions του κάθε item που έχουμε κάνει pickup
	#var hard_pos = []
	#
	##Άμα μετακινείται πιο πολύ οριζόντια (controller compatibility και priority από κάθετα)
	#if (abs(get_horizontal_move()) >= abs(get_vertical_move())):
		#if (get_move("move_right") > get_move("move_left")): #Δεξιά
			#hard_pos = [Vector2(-18.0, -6.0), Vector2(-18.0, -12.0), Vector2(-18.0, -18.0)]
		#else: #Αριστερά
			#hard_pos = [Vector2(18.0, -6.0), Vector2(18.0, -12.0), Vector2(18.0, -18.0)]
	#else: #Άμα μετακινείται πιο πολύ κάθετα
		#if (get_move("move_down") > get_move("move_up")): #Πάνω
			#hard_pos = [Vector2(0.0, -6.0), Vector2(0.0, -12.0), Vector2(0.0, -18.0)]
		#else: #Κάτω
			#hard_pos = [Vector2(0.0, 6.0), Vector2(0.0, 0.0), Vector2(0.0, -6.0)]
	## Assign positions to each marker
	#for i in range(3):
		#get_node("Marker%d" % (i + 1)).position = hard_pos[i]
		
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		get_tree().call_deferred("reload_current_scene")
