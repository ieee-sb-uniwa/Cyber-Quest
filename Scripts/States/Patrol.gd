class_name Patrol
extends State
@export var starting_direction : Vector2 = Vector2(0, 1)
@export var enemy : CharacterBody2D
#onready is used for variable that need to access the scene tree
@onready var animation_tree = $"../../AnimationTree"
@onready var state_machine = animation_tree.get("parameters/playback")
@onready var nav_agent := $"../../NavigationAgent2D" as NavigationAgent2D
@onready var conicalDetectionArea =  $"../../detection_zone/Cone"

var direction : Vector2 = starting_direction
var returns_to_path: bool

func Enter():
	print("Patrolling")
	#enemy.player_in_zone = false
	#enemy.player_in_cone = false
	#enemy.player_visible = false
	conicalDetectionArea.visible = true
	enemy =  $"../.."


func Exit():
	returns_to_path = true

func Physics_update(_delta : float):
	enemy.sprite.set_global_rotation(0)
	if returns_to_path == true:
		nav_test()
	if returns_to_path == false:
		enemy.path_follow.progress += _delta * enemy.move_speed
	if enemy.player_in_cone && enemy.player_visible && enemy.hunting_target.visible==true: 
		transitioned.emit("Chase")



func _on_navigation_agent_2d_target_reached():
	returns_to_path=false
	
func nav_test():
	nav_agent.target_position = enemy.path_follow.global_position
	var current_position= enemy.global_position
	var next_path_position = nav_agent.get_next_path_position()
	var new_velocity = current_position.direction_to(next_path_position) * enemy.move_speed
	
	var direction_to_path = (next_path_position - current_position).normalized()
	
	# Rotate the enemy to face the next path position
	enemy.rotation = direction_to_path.angle()
	if nav_agent.avoidance_enabled:
		nav_agent.set_velocity(new_velocity)
	else: 
		_on_navigation_agent_2d_velocity_computed(new_velocity)
	enemy.move_and_slide()
	


func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	enemy.velocity=safe_velocity
