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
	enemy.player_in_zone = false
	enemy.player_in_cone = false
	enemy.player_visible = false
	enemy =  $"../.."

func Exit():
	returns_to_path = true
#Updates PathFollow2d progress
func Update(delta : float) -> void:
	if returns_to_path == false:
		enemy.path_follow.progress += delta * enemy.move_speed

func Physics_update(_delta : float):
	if returns_to_path == true:
		#print("test"+ %direction.aspect()) to be added
		#Moves the enemies back on the patrol path
		generate_path()
		direction = (nav_agent.get_next_path_position() - enemy.position).normalized()
		enemy.velocity = enemy.velocity.lerp(direction * enemy.move_speed, enemy.acceleration * _delta)
		#Rotate cone to the enemy direction
		conicalDetectionArea.rotation = direction.angle()
		#update_animation_parameters(direction)
		#enemy.move_and_slide()
		#pick_new_animation()
	if enemy.player_in_cone && enemy.player_visible:
		transitioned.emit("Chase")
func update_animation_parameters(move_direction : Vector2):
	if(move_direction != Vector2.ZERO):
		animation_tree.set("parameters/Idle/blend_position", move_direction)
		animation_tree.set("parameters/Move/blend_position", move_direction)
# It generates the return path
func generate_path() -> void:
	if enemy.path_follow != null:
		nav_agent.target_position = enemy.path_follow.position
func pick_new_animation():
	if(enemy.velocity != Vector2.ZERO):
		state_machine.travel("Move")
	else:
		state_machine.travel("Idle")

func _on_navigation_agent_2d_target_reached():
	returns_to_path=false
