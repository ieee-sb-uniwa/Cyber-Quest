extends CharacterBody2D
@export var starting_direction : Vector2 = Vector2(0, 1)
@onready var animated_sprite = $AnimatedSprite2D
@onready var P_collission = $CollisionShape2D
@onready var dialogue_finder: Area2D = $Dialogue_Direction/Dialogue_Finder
@export var inventory: Inventory
@onready var hitbox = $Hitbox
@export var itemHolder : ItemHolder
@export var playerNum: int = 1
var is_hidden:bool = false
var move_speed = 5
var last_animation_look_location : Vector2 = Vector2(0,0)
var move_orientation:Global.MOVE_ORIENTATION = Global.MOVE_ORIENTATION.EMPTY
var movement_enabled = true
var is_respawning:bool=false
var hide_holder = null
var is_interacting_with_box: bool = false

func _ready():
	update_animation_parameters(starting_direction)
	$Hitbox.body_entered.connect(_on_body_entered)
	itemHolder.set_player_index(self.z_index)
	SpawnManager.register_player(playerNum, self)
	Global.players.append(self)
	move_speed = Global.move_speed
	var camera = get_tree().current_scene.get_node("CameraRoot/Camera2D")
	if camera.has_method("assign_player"):
		camera.assign_player(playerNum, self)

func _physics_process(_delta):	
	if is_respawning:
		return  # Skip movement
	var input_direction = Vector2(get_horizontal_move(), get_vertical_move())
	update_animation_parameters(input_direction)
	if movement_enabled:
		velocity = input_direction.normalized() * move_speed
	
	move_and_slide()
	pick_new_state()

func update_animation_parameters(move_input : Vector2):
	if(move_input == Vector2.ZERO):
		return
	var direction = move_input.normalized()
	var abs_x = abs(move_input.x)
	var abs_y = abs(move_input.y)
	move_orientation = Global.MOVE_ORIENTATION.EMPTY
	
	if abs_x > abs_y:
		move_orientation = Global.MOVE_ORIENTATION.RIGHT if direction.x > 0 else Global.MOVE_ORIENTATION.LEFT
		animated_sprite.flip_h = direction.x < 0
	elif abs_y > abs_x:
		move_orientation = Global.MOVE_ORIENTATION.DOWN if direction.y > 0 else Global.MOVE_ORIENTATION.UP
		animated_sprite.flip_h = false
	else:
		# Equal (diagonal): return vertical OR use last pressed key logic
		if abs(last_animation_look_location.x) > 0.1 && abs(last_animation_look_location.y) < 0.1:
			move_orientation = Global.MOVE_ORIENTATION.DOWN if direction.y > 0 else Global.MOVE_ORIENTATION.UP
			animated_sprite.flip_h = false
		elif abs(last_animation_look_location.y) > 0.1 && abs(last_animation_look_location.x) < 0.1:
			move_orientation = Global.MOVE_ORIENTATION.RIGHT if direction.x > 0 else Global.MOVE_ORIENTATION.LEFT
			animated_sprite.flip_h = direction.x < 0
		else:
			return
	
	itemHolder.change_items_orientation(move_orientation)

func pick_new_state():
	var is_moving = velocity != Vector2.ZERO
	var animation_name = ""
	
	if is_moving:
		match move_orientation:
			Global.MOVE_ORIENTATION.UP:
				animation_name = "move_back"
			Global.MOVE_ORIENTATION.DOWN:
				animation_name = "move_front"
			Global.MOVE_ORIENTATION.LEFT, Global.MOVE_ORIENTATION.RIGHT:
				animation_name = "move_side"
	else:
		match move_orientation:
			Global.MOVE_ORIENTATION.UP:
				animation_name = "idle_back"
			Global.MOVE_ORIENTATION.DOWN:
				animation_name = "idle_front"
			Global.MOVE_ORIENTATION.LEFT, Global.MOVE_ORIENTATION.RIGHT:
				animation_name = "idle_side"
	
	if animation_name != "" and animated_sprite.animation != animation_name:
		animated_sprite.play(animation_name)

func player(): #Is used to be identified by enemies
	pass

# Getters 		
func get_movement_inputs() -> Vector2:
	return Vector2(get_horizontal_move(), get_vertical_move())
	
func get_move(move):
	return Input.get_action_strength(move)
	
func get_horizontal_move():
	return get_move("move_right_p" + str(playerNum)) - get_move("move_left_p" + str(playerNum))

func get_vertical_move():
	return get_move("move_down_p" + str(playerNum)) - get_move("move_up_p" + str(playerNum))
	
func get_all_items() -> Array[Node2D]:
	return itemHolder.get_all_items()

func add_item_to_holder(item : Node2D) -> void:
	itemHolder.add_item(item)

func clear_all_items() -> void:
	itemHolder.clear_all_items(self, true)
		
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy") && !is_hidden: 
		for i in Global.players.size():
			Global.players[i].on_death()
		SpawnManager.respawn_players()
		body.change_state("PatrolNav")

func on_death() -> void:
	if hide_holder:
		hide_holder.toggle_hide()
	itemHolder.clear_all_items(self, false)

func set_interacting_with_box(interacting: bool):
	is_interacting_with_box = interacting
	if interacting:
		move_speed = Global.move_speed * 0.4  # 40% of normal speed, adjust as needed
	else:
		move_speed = Global.move_speed

func is_interacting() -> bool:
	var action_name = "Interact_p" + str(playerNum)
	return Input.is_action_pressed(action_name)

func _unhandled_input(_event: InputEvent) -> void: # Για διάλογο
	if Input.is_action_just_pressed("Dialogue_Find"): #Βλέπει αμα μπορεί να εκτελέση το διάλογο εφόσον υπάρχει το σωστό area
		var dialogue = dialogue_finder.get_overlapping_areas()
		if dialogue.size() > 0:
			dialogue[0].action()
			return
