extends Area2D

# Exported variables for customization
@export var move_speed := 100.0

# State variables
var is_grabbed := false
var player_ref: Node2D = null
var original_collision_layer: int
var original_collision_mask: int

# Reference to collision shapes
@onready var collision_shape := $CollisionShape2D
@onready var interaction_area_h := $InteractionAreaH
@onready var interaction_area_v := $InteractionAreaV

func _ready():
	# Store original collision properties
	original_collision_layer = collision_layer
	original_collision_mask = collision_mask
	
	# Connect interaction area signals
	interaction_area_h.body_entered.connect(_on_interaction_area_entered)
	interaction_area_v.body_entered.connect(_on_interaction_area_entered)
	interaction_area_h.body_exited.connect(_on_interaction_area_exited)
	interaction_area_v.body_exited.connect(_on_interaction_area_exited)

func _on_interaction_area_entered(body):
	# Check if the entering body is a player
	if (body.is_in_group("player1") or body.is_in_group("player2")) and player_ref == null:
		player_ref = body

func _on_interaction_area_exited(body):
	# Check if the exiting body is the player we're tracking
	if body == player_ref:
		player_ref = null
		# Auto-release if player leaves area while grabbing
		if is_grabbed:
			release_box()

func _process(_delta):
	# Check for interaction input from the current player
	if player_ref != null and Input.is_action_just_pressed(_get_interaction_button()):
		if is_grabbed:
			release_box()
		else:
			grab_box()

func _physics_process(delta):
	if is_grabbed and player_ref != null:
		# Get movement direction based on player input
		var move_direction = _get_movement_direction()
		
		# Apply movement
		if move_direction != Vector2.ZERO:
			position += move_direction * move_speed * delta
			
			# Update player position to stay aligned with box
			_align_player_with_box()

func _get_interaction_button() -> String:
	if player_ref == null:
		return ""
	
	if player_ref.is_in_group("player1"):
		return "Interact_p1"
	elif player_ref.is_in_group("player2"):
		return "Interact_p2"
	
	return ""

func _get_movement_direction() -> Vector2:
	var move_direction = Vector2.ZERO
	
	# Determine which input actions to use based on player
	var left_action = "move_left"
	var right_action = "move_right"
	var up_action = "move_up"
	var down_action = "move_down"
	
	if player_ref.is_in_group("player2"):
		# Try player 2 specific controls, fall back to default if not defined
		left_action = "move_left_p2" if InputMap.has_action("move_left_p2") else left_action
		right_action = "move_right_p2" if InputMap.has_action("move_right_p2") else right_action
		up_action = "move_up_p2" if InputMap.has_action("move_up_p2") else up_action
		down_action = "move_down_p2" if InputMap.has_action("move_down_p2") else down_action
	
	# Check input
	if Input.is_action_pressed(right_action):
		move_direction.x = 1
	elif Input.is_action_pressed(left_action):
		move_direction.x = -1
	
	if Input.is_action_pressed(down_action):
		move_direction.y = 1
	elif Input.is_action_pressed(up_action):
		move_direction.y = -1
	
	return move_direction

func _align_player_with_box():
	# Calculate direction from box to player
	var direction_to_player = (player_ref.global_position - global_position).normalized()
	
	# Position player at a fixed distance from the box
	var player_distance = 20  # Adjust this value as needed
	player_ref.global_position = global_position + direction_to_player * player_distance

func grab_box():
	if player_ref == null:
		return
		
	is_grabbed = true
	
	# Change collision layers to prevent player from colliding with box while moving it
	collision_layer = 0
	collision_mask = 0
	
	# Optional: Visual feedback when grabbed
	modulate = Color(0.8, 0.8, 1.0)  # Slight blue tint

func release_box():
	is_grabbed = false
	
	# Restore original collision properties
	collision_layer = original_collision_layer
	collision_mask = original_collision_mask
	
	# Restore original color
	modulate = Color.WHITE
