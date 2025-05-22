extends CharacterBody2D

@export var starting_direction : Vector2 = Vector2(0, 1)
@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")
@export var inventory: Inventory
@onready var hitbox = $Hitbox

## Pickup Item Functionality ##
var items_picked_up : int = 0
## ---- ##
@onready var P_sprite = $Sprite2D
@onready var P_collission = $CollisionShape2D

func _ready():
	update_animation_parameters(starting_direction)
	$Hitbox.body_entered.connect(_on_body_entered)

func _physics_process(_delta):	
	var input_direction = Vector2(get_horizontal_move(), get_vertical_move())
	update_animation_parameters(input_direction)
	
	velocity = input_direction.normalized() * Global.move_speed
	pickup_item_positions()
	
	move_and_slide()
	pick_new_state()

func update_animation_parameters(move_input : Vector2):
	if(move_input != Vector2.ZERO):
		animation_tree.set("parameters/Idle/blend_position", move_input)
		animation_tree.set("parameters/Move/blend_position", move_input)

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
	return get_move("move_right") - get_move("move_left")

func get_vertical_move():
	return get_move("move_down") - get_move("move_up")
	
func pickup_item_positions():	
	# If no movement, don't do anything
	if (velocity == Vector2.ZERO):
		return
	# Hardcoded positions του κάθε item που έχουμε κάνει pickup
	var hard_pos = []
	
	#Άμα μετακινείται πιο πολύ οριζόντια (controller compatibility και priority από κάθετα)
	if (abs(get_horizontal_move()) >= abs(get_vertical_move())):
		if (get_move("move_right") > get_move("move_left")): #Δεξιά
			hard_pos = [Vector2(-18.0, -6.0), Vector2(-18.0, -12.0), Vector2(-18.0, -18.0)]
		else: #Αριστερά
			hard_pos = [Vector2(18.0, -6.0), Vector2(18.0, -12.0), Vector2(18.0, -18.0)]
	else: #Άμα μετακινείται πιο πολύ κάθετα
		if (get_move("move_down") > get_move("move_up")): #Πάνω
			hard_pos = [Vector2(0.0, -6.0), Vector2(0.0, -12.0), Vector2(0.0, -18.0)]
		else: #Κάτω
			hard_pos = [Vector2(0.0, 6.0), Vector2(0.0, 0.0), Vector2(0.0, -6.0)]
	# Assign positions to each marker
	for i in range(3):
		get_node("Marker%d" % (i + 1)).position = hard_pos[i]
		
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		get_tree().reload_current_scene()
