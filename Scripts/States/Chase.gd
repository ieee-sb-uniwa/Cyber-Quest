class_name Chase
extends State
@onready var sprite : Sprite2D = $"../../Sprite2D"
@onready var collision : CollisionShape2D = $"../../detection_zone/CollisionShape2D"
@export var enemy : CharacterBody2D
@export var starting_direction : Vector2 = Vector2(0, 0)
@onready var animation_tree = $"../../AnimationTree"
@onready var state_machine = animation_tree.get("parameters/playback")
@export var target : CharacterBody2D 
@onready var nav_agent := $"../../NavigationAgent2D" as NavigationAgent2D
var player_in_zone : bool
func Enter():
	player_in_zone = true
	enemy = $"../.."
	target = get_tree().get_first_node_in_group("Player")
	update_animation_parameters(starting_direction)
func Physics_update(_delta: float) -> void:
	# moving enemy by position no collisions...
	#enemy.position += (target.position - enemy.position) / enemy.move_speed
	# moving enemy by velocity supports collisions with move and slide...
	#var direction = enemy.global_position.direction_to(target.global_position)
	# get direction with smart pathfinding AStar algorithm
	var direction = enemy.to_local(nav_agent.get_next_path_position()).normalized()
	update_animation_parameters(direction)
	enemy.velocity = direction * enemy.move_speed
	enemy.move_and_slide()
	pick_new_animation()
	if !player_in_zone:
		transitioned.emit("Patrol")
func update_animation_parameters(move_direction : Vector2):
	if(move_direction != Vector2.ZERO):
		animation_tree.set("parameters/Idle/blend_position", move_direction)
		animation_tree.set("parameters/Move/blend_position", move_direction)
func pick_new_animation():
	if(enemy.velocity != Vector2.ZERO):
		state_machine.travel("Move")
	else:
		state_machine.travel("Idle")
func generate_path() -> void:
	nav_agent.target_position = target.position
func _on_detection_zone_body_exited(body):
	if body.has_method("player"):
		player_in_zone=false
func _on_timer_timeout():
	generate_path()
