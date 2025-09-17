extends RigidBody2D

@export var speed: float = 120.0
@export var max_grab_distance: float = 300.0  # 0 = απενεργοποιημένο
@onready var area = $InteractionArea

var grabbers: Array[CharacterBody2D] = []
var nearby_players: Array = []
var velocity: Vector2 = Vector2.ZERO

func _ready() -> void:
	area.body_entered.connect(_on_box_area_body_entered)
	area.body_exited.connect(_on_box_area_body_exited)
	gravity_scale = 0.0
	area.set_object_type("movebox")
	area.interaction_status = Global.INTERACTION_STATUS.AVAILABLE

func _process(_delta: float) -> void:
	# ελέγχουμε για νέους παίκτες που πατάνε interact
	for p in nearby_players:
		if _is_player_interacting(p) and not grabbers.has(p):
			_grab(p)

	# ελέγχουμε για παίκτες που άφησαν το interact ή απομακρύνθηκαν
	for g in grabbers.duplicate():
		if not _is_player_interacting(g):
			_release(g)
		elif max_grab_distance > 0 and g.global_position.distance_to(global_position) > max_grab_distance:
			_release(g)

func _physics_process(_delta: float) -> void:
	if grabbers.size() > 0:
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
			velocity = total_dir.normalized() * speed
		else:
			velocity = Vector2.ZERO
	else:
		velocity = Vector2.ZERO

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	state.linear_velocity = velocity

func _on_box_area_body_entered(body: Node) -> void:
	print("Entered:", body)
	if body is CharacterBody2D and not nearby_players.has(body):
		nearby_players.append(body)
		print("Player added:", body.name)

func _on_box_area_body_exited(body: Node) -> void:
	if body is CharacterBody2D:
		nearby_players.erase(body)
		_release(body)

func _is_player_interacting(p: CharacterBody2D) -> bool:
	if p == null: 
		return false
	var action_name := "Interact_p" + str(p.playerNum)
	if Input.is_action_pressed(action_name): 
		return true
	if p.has_method("is_interacting") and p.is_interacting(): 
		return true
	return false

func _grab(p: CharacterBody2D) -> void:
	grabbers.append(p)

func _release(p: CharacterBody2D) -> void:
	grabbers.erase(p)
	if grabbers.size() == 0:
		linear_velocity = Vector2.ZERO
		velocity = Vector2.ZERO

# Signals from InteractionArea	
func _on_body_exited(_body:Node2D) -> void:
	pass 

func _on_body_entered(_body:Node2D) -> void:
	pass 