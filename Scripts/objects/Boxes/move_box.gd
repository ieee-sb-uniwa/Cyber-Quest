extends Node2D

@export var speed_multiplier: float = 0.4
@export var max_grab_distance: float = 300.0

var grabbers: Array[CharacterBody2D] = []
var nearby_players_v: Array[CharacterBody2D] = []
var nearby_players_h: Array[CharacterBody2D] = []

var speed: float = 0.0
var velocity: Vector2 = Vector2.ZERO
var move_orientation: String = ""  # "vertical", "horizontal", or ""

@onready var area_v: Area2D = $InteractionAreaV
@onready var area_h: Area2D = $InteractionAreaH

func _ready() -> void:
	# Initialize speed based on global move speed
	speed = Global.move_speed * speed_multiplier
	
	# Connect vertical area signals
	area_v.body_entered.connect(_on_body_entered_v)
	area_v.body_exited.connect(_on_body_exited_v)
	# Connect horizontal area signals
	area_h.body_entered.connect(_on_body_entered_h)
	area_h.body_exited.connect(_on_body_exited_h)

func _process(_delta: float) -> void:
	# Check for toggle interactions
	for p in nearby_players_v + nearby_players_h:
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

	if total_dir != Vector2.ZERO:
		# Restrict movement based on area
		if move_orientation == "horizontal":
			total_dir.y = 0
		elif move_orientation == "vertical":
			total_dir.x = 0
		velocity = total_dir.normalized() * speed
	else:
		velocity = Vector2.ZERO
	
	# Apply movement directly to position
	position += velocity * delta

# --- Area signals ---

func _on_body_entered_v(body: Node) -> void:
	if body is CharacterBody2D and not nearby_players_v.has(body):
		nearby_players_v.append(body)
		_update_move_orientation()
		# print("Vertical zone: player nearby")

func _on_body_exited_v(body: Node) -> void:
	if body is CharacterBody2D:
		nearby_players_v.erase(body)
		# Only release if they were grabbing
		if grabbers.has(body):
			_release(body)
		_update_move_orientation()

func _on_body_entered_h(body: Node) -> void:
	if body is CharacterBody2D and not nearby_players_h.has(body):
		nearby_players_h.append(body)
		_update_move_orientation()
		# print("Horizontal zone: player nearby")

func _on_body_exited_h(body: Node) -> void:
	if body is CharacterBody2D:
		nearby_players_h.erase(body)
		# Only release if they were grabbing
		if grabbers.has(body):
			_release(body)
		_update_move_orientation()

func _update_move_orientation() -> void:
	if nearby_players_h.size() > 0:
		move_orientation = "horizontal"
	elif nearby_players_v.size() > 0:
		move_orientation = "vertical"
	else:
		move_orientation = ""

# --- Player interaction ---

func _is_player_toggling_interaction(p: CharacterBody2D) -> bool:
	if p == null:
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
		# print("Grabbed box, orientation:", move_orientation)

func _release(p: CharacterBody2D) -> void:
	grabbers.erase(p)
	# Reset the player's interaction state
	if p != null and p.has_method("set_interacting_with_box"):
		p.set_interacting_with_box(false)
	if grabbers.size() == 0:
		velocity = Vector2.ZERO
	# print("Released box")
