extends CharacterBody2D

@export var speed_multiplier: float = 0.4
@export var max_grab_distance: float = 300.0

var grabbers: Array[CharacterBody2D] = []
var nearby_players_left: Array[CharacterBody2D] = []
var nearby_players_right: Array[CharacterBody2D] = []
var nearby_players_up: Array[CharacterBody2D] = []
var nearby_players_down: Array[CharacterBody2D] = []

var speed: float = 0.0
var move_orientation: String = ""  # "vertical", "horizontal", or ""

@onready var area_left: Area2D = $InteractionAreaL
@onready var area_right: Area2D = $InteractionAreaR
@onready var area_up: Area2D = $InteractionAreaU
@onready var area_down: Area2D = $InteractionAreaD

func _ready() -> void:
	# Initialize speed based on global move speed
	speed = Global.move_speed * speed_multiplier
	
	# Debug: Print all area nodes to make sure they're found
	# print("Box areas found:")
	# print("Left: ", area_left != null)
	# print("Right: ", area_right != null)
	# print("Up: ", area_up != null)
	# print("Down: ", area_down != null)
	
	# Connect area signals for all four sides
	area_left.body_entered.connect(_on_body_entered_left)
	area_left.body_exited.connect(_on_body_exited_left)
	
	area_right.body_entered.connect(_on_body_entered_right)
	area_right.body_exited.connect(_on_body_exited_right)
	
	area_up.body_entered.connect(_on_body_entered_up)
	area_up.body_exited.connect(_on_body_exited_up)
	
	area_down.body_entered.connect(_on_body_entered_down)
	area_down.body_exited.connect(_on_body_exited_down)

func _process(_delta: float) -> void:
	# Check for toggle interactions
	var all_nearby_players = nearby_players_left + nearby_players_right + nearby_players_up + nearby_players_down
	for p in all_nearby_players:
		if _is_player_toggling_interaction(p):
			_toggle_player_interaction(p)

	# Release players who are too far away
	for g in grabbers.duplicate():
		if max_grab_distance > 0 and g.global_position.distance_to(global_position) > max_grab_distance:
			_release(g)

func _physics_process(delta: float) -> void:
	if grabbers.size() == 0:
		velocity = Vector2.ZERO
		return

	var total_dir := Vector2.ZERO
	for g in grabbers:
		var input_dir := Vector2.ZERO
		if g.has_method("get_horizontal_move") and g.has_method("get_vertical_move"):
			input_dir = Vector2(g.get_horizontal_move(), g.get_vertical_move())
		else:
			input_dir = Vector2(
				Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
				Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
			)
		total_dir += input_dir
		
		# Only update player orientation when they're actually moving the box
		# This prevents overriding the player's regular animation when not moving
		if input_dir != Vector2.ZERO and g.has_method("update_box_interaction_orientation"):
			var player_side = _get_player_side(g)
			g.update_box_interaction_orientation(player_side)

	if total_dir != Vector2.ZERO:
		# Restrict movement based on area
		if move_orientation == "horizontal":
			total_dir.y = 0
		elif move_orientation == "vertical":
			total_dir.x = 0
		velocity = total_dir.normalized() * speed
	else:
		velocity = Vector2.ZERO
	
	# Use move_and_collide for proper collision handling
	var collision = move_and_collide(velocity * delta)
	if collision:
		# Handle collision - stop movement
		velocity = Vector2.ZERO
		# print("Box collided with: ", collision.get_collider().name)

# --- Area signals ---

func _on_body_entered_left(body: Node) -> void:
	if body is CharacterBody2D and "playerNum" in body and not nearby_players_left.has(body):
		nearby_players_left.append(body)
		_update_move_orientation()
		# print("Left side: player entered. Total left players: ", nearby_players_left.size())

func _on_body_exited_left(body: Node) -> void:
	if body is CharacterBody2D:
		nearby_players_left.erase(body)
		# Only release if they were grabbing
		if grabbers.has(body):
			_release(body)
		_update_move_orientation()
		# print("Left side: player exited. Total left players: ", nearby_players_left.size())

func _on_body_entered_right(body: Node) -> void:
	if body is CharacterBody2D and "playerNum" in body and not nearby_players_right.has(body):
		nearby_players_right.append(body)
		_update_move_orientation()
		# print("Right side: player entered. Total right players: ", nearby_players_right.size())

func _on_body_exited_right(body: Node) -> void:
	if body is CharacterBody2D:
		nearby_players_right.erase(body)
		# Only release if they were grabbing
		if grabbers.has(body):
			_release(body)
		_update_move_orientation()
		# print("Right side: player exited. Total right players: ", nearby_players_right.size())

func _on_body_entered_up(body: Node) -> void:
	if body is CharacterBody2D and "playerNum" in body and not nearby_players_up.has(body):
		nearby_players_up.append(body)
		_update_move_orientation()
		# print("Up side: player entered. Total up players: ", nearby_players_up.size())

func _on_body_exited_up(body: Node) -> void:
	if body is CharacterBody2D:
		nearby_players_up.erase(body)
		# Only release if they were grabbing
		if grabbers.has(body):
			_release(body)
		_update_move_orientation()
		# print("Up side: player exited. Total up players: ", nearby_players_up.size())

func _on_body_entered_down(body: Node) -> void:
	if body is CharacterBody2D and "playerNum" in body and not nearby_players_down.has(body):
		nearby_players_down.append(body)
		_update_move_orientation()
		# print("Down side: player entered. Total down players: ", nearby_players_down.size())

func _on_body_exited_down(body: Node) -> void:
	if body is CharacterBody2D:
		nearby_players_down.erase(body)
		# Only release if they were grabbing
		if grabbers.has(body):
			_release(body)
		_update_move_orientation()
		# print("Down side: player exited. Total down players: ", nearby_players_down.size())

func _update_move_orientation() -> void:
	# Debug: Print current state
	# print("Update orientation - Left: ", nearby_players_left.size(), 
		#   ", Right: ", nearby_players_right.size(),
		#   ", Up: ", nearby_players_up.size(),
		#   ", Down: ", nearby_players_down.size())
	
	# Horizontal areas have priority over vertical areas
	if nearby_players_left.size() > 0 or nearby_players_right.size() > 0:
		move_orientation = "horizontal"
	elif nearby_players_up.size() > 0 or nearby_players_down.size() > 0:
		move_orientation = "vertical"
	else:
		move_orientation = ""
	
	# print("New orientation: ", move_orientation)

# Helper function to determine which side a player is on
func _get_player_side(player: CharacterBody2D) -> String:
	if nearby_players_left.has(player):
		return "left"
	elif nearby_players_right.has(player):
		return "right"
	elif nearby_players_up.has(player):
		return "up"
	elif nearby_players_down.has(player):
		return "down"
	return ""

# --- Player interaction ---

func _is_player_toggling_interaction(p: CharacterBody2D) -> bool:
	if p == null or not "playerNum" in p:
		return false
	var action_name := "Interact_p" + str(p.playerNum)
	return Input.is_action_just_pressed(action_name)

func _toggle_player_interaction(p: CharacterBody2D) -> void:
	if grabbers.has(p):
		_release(p)
	else:
		_grab(p)

func _grab(p: CharacterBody2D) -> void:
	if not grabbers.has(p):
		grabbers.append(p)
		# Set the player's interaction state
		if p.has_method("set_interacting_with_box"):
			p.set_interacting_with_box(true)

		# Mark all areas as occupied
		area_left.occupied = true
		area_right.occupied = true
		area_up.occupied = true
		area_down.occupied = true

		InteractionManager.unregister_area(area_left)
		InteractionManager.unregister_area(area_right)
		InteractionManager.unregister_area(area_up)
		InteractionManager.unregister_area(area_down)

		# print("Grabbed box, side:", _get_player_side(p))

func _release(p: CharacterBody2D) -> void:
	grabbers.erase(p)
	# Reset the player's interaction state
	if p != null and p.has_method("set_interacting_with_box"):
		p.set_interacting_with_box(false)
	if p != null and p.has_method("reset_box_orientation"):
		p.reset_box_orientation()
	if grabbers.size() == 0:
		velocity = Vector2.ZERO

		# Clear occupied flag when no one is grabbing
		area_left.occupied = false
		area_right.occupied = false
		area_up.occupied = false
		area_down.occupied = false

		if nearby_players_left.size() > 0:
			InteractionManager.register_area(area_left, nearby_players_left[0])
		if nearby_players_right.size() > 0:
			InteractionManager.register_area(area_right, nearby_players_right[0])
		if nearby_players_up.size() > 0:
			InteractionManager.register_area(area_up, nearby_players_up[0])
		if nearby_players_down.size() > 0:
			InteractionManager.register_area(area_down, nearby_players_down[0])
	# print("Released box")
