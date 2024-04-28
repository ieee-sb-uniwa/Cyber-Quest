class_name Patrol
extends State
var detectionCollision : CollisionShape2D
@export var starting_direction : Vector2 = Vector2(0, 1)
@onready var animation_tree = $"../../AnimationTree"
@onready var state_machine = animation_tree.get("parameters/playback")
@onready var nav_agent := $"../../NavigationAgent2D" as NavigationAgent2D
@onready var path_follow : PathFollow2D = $"../../../PatrolPaths/Path2D/PathFollow2D"
var player_in_zone: bool
var returns_to_path: bool
var target : CharacterBody2D
var enemy : CharacterBody2D
func Enter():
	player_in_zone = false
	target = get_tree().get_first_node_in_group("Player")
	enemy =  $"../.."
	detectionCollision = $"../../detection_zone/CollisionShape2D"
	update_animation_parameters(starting_direction)
func Exit():
	returns_to_path = true
func Update(delta : float) -> void:
	if returns_to_path == false:
		path_follow.progress += delta * enemy.move_speed
func Physics_update(delta):
	if returns_to_path == true:
		generate_path()
		var direction = enemy.to_local(nav_agent.get_next_path_position()).normalized()
		enemy.velocity = direction * enemy.move_speed 
		update_animation_parameters(direction)
		enemy.move_and_slide()
		pick_new_animation()
	if player_in_zone:
		transitioned.emit("Chase")
func update_animation_parameters(move_direction : Vector2):
	if(move_direction != Vector2.ZERO):
		animation_tree.set("parameters/Idle/blend_position", move_direction)
		animation_tree.set("parameters/Move/blend_position", move_direction)
# It generates the return path
func generate_path() -> void:
	if path_follow != null:
		nav_agent.target_position = path_follow.position
func pick_new_animation():
	if(enemy.velocity != Vector2.ZERO):
		state_machine.travel("Move")
	else:
		state_machine.travel("Idle")
#
func _on_detection_zone_body_entered(body):
	if body.has_method("player"):
		player_in_zone = true
		target = body
func _on_navigation_agent_2d_target_reached():
	returns_to_path=false
