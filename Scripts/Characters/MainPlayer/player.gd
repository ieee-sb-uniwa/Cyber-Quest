extends CharacterBody2D
@export var starting_direction : Vector2 = Vector2(0, 1)
@onready var animated_sprite = $AnimatedSprite2D
@onready var P_collission = $CollisionShape2D
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
var box_interaction_side: String = ""  # "left", "right", "up", "down"
var last_move_orientation: Global.MOVE_ORIENTATION = Global.MOVE_ORIENTATION.DOWN  # Store last movement orientation
var keep_box_orientation: bool = false  # Flag to keep box orientation until movement

func _ready():
	update_animation_parameters(starting_direction)
	$Hitbox.body_entered.connect(_on_body_entered)
	itemHolder.set_player_index(self.z_index)
	SpawnManager.register_player(playerNum, self)
	Global.players.append(self)
	move_speed = Global.move_speed


func _exit_tree() -> void:
	# Unregister from spawn manager and global players list
	if typeof(SpawnManager) != TYPE_NIL:
		if SpawnManager.has_method("unregister_player"):
			SpawnManager.unregister_player(self)
	for i in range(Global.players.size()):
		if Global.players[i] == self:
			Global.players.remove_at(i)
			break

func _physics_process(_delta):	
	if is_respawning:
		return  # Skip movement
	var input_direction = Vector2(get_horizontal_move(), get_vertical_move())
	
	# If we're moving, clear the keep_box_orientation flag
	if input_direction != Vector2.ZERO and keep_box_orientation:
		keep_box_orientation = false
		box_interaction_side = ""
	
	update_animation_parameters(input_direction)
	
	if movement_enabled:
		velocity = input_direction.normalized() * move_speed
	
	move_and_slide()
	pick_new_state()
	update_animation()


func pick_new_state():
	var is_moving = velocity != Vector2.ZERO
	var animation_name = ""
	
	# If we're keeping box orientation, use the appropriate animation
	if keep_box_orientation and box_interaction_side != "":
		if is_moving:
			match box_interaction_side:
				"left", "right":
					animation_name = "move_side"
				"up":
					animation_name = "move_front"
				"down":
					animation_name = "move_back"
		else:
			match box_interaction_side:
				"left", "right":
					animation_name = "idle_side"
				"up":
					animation_name = "idle_front"
				"down":
					animation_name = "idle_back"
	else:
		# Normal movement animations
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
		# iterate safely over players (avoid calling methods on freed/null instances)
		for p in Global.players.duplicate():
			if p != null and is_instance_valid(p):
				p.on_death()
		SpawnManager.respawn_players()
		if body.has_method("change_state"):
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
		# Set flag to keep box orientation until movement
		keep_box_orientation = true

func is_interacting() -> bool:
	var action_name = "Interact_p" + str(playerNum)
	return Input.is_action_pressed(action_name)

func update_animation_parameters(move_input : Vector2):
	# If we're keeping box orientation, don't update based on movement
	if keep_box_orientation and box_interaction_side != "":
		return
		
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
	
	# Store the last movement orientation
	last_move_orientation = move_orientation
	
	# Pass the flip state to the item holder
	itemHolder.change_items_orientation(move_orientation, animated_sprite.flip_h)

func update_box_interaction_orientation(side: String):
	box_interaction_side = side
	
	# Update animation based on side
	if side == "left":
		# Player is on the left side - face right to push the box
		$AnimatedSprite2D.animation = "move_side"
		$AnimatedSprite2D.flip_h = false
		itemHolder.change_items_orientation(Global.MOVE_ORIENTATION.RIGHT, false)
	elif side == "right":
		# Player is on the right side - face left to push the box
		$AnimatedSprite2D.animation = "move_side"
		$AnimatedSprite2D.flip_h = true
		itemHolder.change_items_orientation(Global.MOVE_ORIENTATION.LEFT, true)
	elif side == "up":
		# Player is on the top - face down to push the box
		$AnimatedSprite2D.animation = "move_front"
		$AnimatedSprite2D.flip_h = false
		itemHolder.change_items_orientation(Global.MOVE_ORIENTATION.DOWN, false)
	elif side == "down":
		# Player is on the bottom - face up to push the box
		$AnimatedSprite2D.animation = "move_back"
		$AnimatedSprite2D.flip_h = false
		itemHolder.change_items_orientation(Global.MOVE_ORIENTATION.UP, false)

# Update your animation function to account for box interaction
func update_animation():
	# If interacting with box or keeping box orientation, use box interaction animations
	if (is_interacting_with_box or keep_box_orientation) and box_interaction_side != "":
		if velocity.length() > 0:
			# Moving while interacting
			match box_interaction_side:
				"left", "right":
					$AnimatedSprite2D.animation = "move_side"
					$AnimatedSprite2D.flip_h = (box_interaction_side == "right")
				"up":
					$AnimatedSprite2D.animation = "move_front"
				"down":
					$AnimatedSprite2D.animation = "move_back"
		else:
			# Standing while interacting
			match box_interaction_side:
				"left", "right":
					$AnimatedSprite2D.animation = "idle_side"
					$AnimatedSprite2D.flip_h = (box_interaction_side == "right")
				"up":
					$AnimatedSprite2D.animation = "idle_front"
				"down":
					$AnimatedSprite2D.animation = "idle_back"
