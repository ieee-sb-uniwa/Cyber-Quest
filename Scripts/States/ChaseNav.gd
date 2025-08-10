class_name ChaseNav
extends State
@onready var sprite : Sprite2D = $"../../Sprite2D"
@onready var enemy : Enemy_nav = $"../.."
@onready var animation_tree = $"../../AnimationTree"
@onready var state_machine = animation_tree.get("parameters/playback")
@onready var nav_agent: NavigationAgent2D = $"../../NavigationAgent2D"
@onready var conicalDetectionArea: CollisionPolygon2D = $"../../detection_zone/Cone"

var current_target : Node2D = null
var is_checking_lost_target : bool = false

func Enter():
	print("Chasing")
	#enemy.player_in_zone = true
	#enemy.player_in_cone = true
	#enemy.player_visible = true
	
func Exit():
	current_target = null
	is_checking_lost_target = false

func Physics_update(_delta: float) -> void:
	var hunting_targets = enemy.hunting_targets
	if(hunting_targets.size() == 0):
		if current_target.is_hidden:
			switch_state("PatrolNav")
			return
		check_lost_target(3.0)
	
	if current_target != null:
		var direction_to_player = (current_target.global_position - enemy.global_position).normalized()
		enemy.rotation = direction_to_player.angle()  # Rotate the enemy to face the player
		enemy.sprite.set_global_rotation(0)
		nav_test()
		return
	
	if current_target == null || hunting_targets.find(current_target)==-1:
		current_target = get_closest_target(hunting_targets)
	#Rotate cone 
	#conicalDetectionArea.rotation = direction_to_player.angle()
	
		
func get_closest_target(targets: Array[Node2D]) -> Node2D:
	if targets.is_empty():
		return null
	var closest: Node2D = targets[0]
	var closest_distance: float = enemy.global_position.distance_to(closest.global_position)
	for target in targets:
		var dist = enemy.global_position.distance_to(target.global_position)
		if dist < closest_distance:
			closest = target
			closest_distance = dist
	return closest

func check_lost_target(duration: float) -> void:
	if is_checking_lost_target:
		return
	is_checking_lost_target = true
	var start_time := Time.get_ticks_msec()
	while Time.get_ticks_msec() - start_time < int(duration * 1000):
		if get_tree() == null:
			print("Tree is null!")
			return;
		await get_tree().physics_frame
		if enemy.hunting_targets.size() > 0:
				is_checking_lost_target = false
				return  # Enemy is back, cancel patrol transition
	is_checking_lost_target = false
	switch_state("PatrolNav")
	
func switch_state(state_name: String) -> void:
	print("Switching state to " + state_name)
	transitioned.emit(state_name)

func nav_test():
	nav_agent.target_position = current_target.global_position
	var current_position= enemy.global_position
	var next_path_position = nav_agent.get_next_path_position()
	var new_velocity = current_position.direction_to(next_path_position) * enemy.move_speed
	if nav_agent.avoidance_enabled:
		nav_agent.set_velocity(new_velocity)
	else: 
		_on_navigation_agent_2d_velocity_computed(new_velocity)
	enemy.move_and_slide()

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	enemy.velocity=safe_velocity
