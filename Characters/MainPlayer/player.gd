extends CharacterBody2D

@export var starting_direction : Vector2 = Vector2(0, 1)
@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")
@export var inventory: Inventory

## Pickup Item Functionality ##
var items_picked_up : int = 0
## ---- ##
@onready var P_sprite = $Sprite2D
@onready var P_collission = $CollisionShape2D

func _ready():
	update_animation_parameters(starting_direction)

func _physics_process(_delta):	
	var input_direction = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)
	update_animation_parameters(input_direction)
	velocity = input_direction.normalized() * Global.move_speed
	#region Pickup Item Functionality
	if (abs(Input.get_action_strength("move_right") - Input.get_action_strength("move_left")) >=
	abs(Input.get_action_strength("move_down") - Input.get_action_strength("move_up"))
	and velocity != Vector2.ZERO): #Άμα μετακινείται πιο πολύ οριζόντια (controller compatibility και priority από κάθετα)
		if (Input.get_action_strength("move_right") > Input.get_action_strength("move_left")): #Δεξιά
			get_node("Marker1").position = Vector2(-18.0,-6.0) #Hardcoded positions του κάθε item που έχουμε κάνει pickup
			get_node("Marker2").position = Vector2(-18.0,-12.0)
			get_node("Marker3").position = Vector2(-18.0,-18.0)
		else: #Αριστερά ☭
			get_node("Marker1").position = Vector2(18.0,-6.0)
			get_node("Marker2").position = Vector2(18.0,-12.0)
			get_node("Marker3").position = Vector2(18.0,-18.0)
	elif (velocity != Vector2.ZERO): #Άμα μετακινείται πιο πολύ κάθετα
		if (Input.get_action_strength("move_down") > Input.get_action_strength("move_up")): #Πάνω
			get_node("Marker1").position = Vector2(0.0,-6.0)
			get_node("Marker2").position = Vector2(0.0,-12.0)
			get_node("Marker3").position = Vector2(0.0,-18.0)
		else: #Κάτω
			get_node("Marker1").position = Vector2(0.0,6.0)
			get_node("Marker2").position = Vector2(0.0,0.0)
			get_node("Marker3").position = Vector2(0.0,-6.0)
	#endregion
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
func _input(event):
	if event.is_action_pressed("Interact"):
		if Global.Hide_status == 1 && Global.interacable == true:
			self.visible=false
			P_sprite.visible = false
			set_collision_layer_value(30,true)
			set_collision_layer_value(1,false)
			Global.move_speed = 0
		else:
			if Global.Hide_status == 0 && Global.interacable == true:
				self.visible=true
				P_sprite.visible = true 
				set_collision_layer_value(1,true)
				set_collision_layer_value(30,false)
				Global.move_speed = 150
