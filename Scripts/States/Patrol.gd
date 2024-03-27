class_name Patrol
extends State
var collision : CollisionShape2D
@export var starting_direction : Vector2 = Vector2(0, 0)
@onready var animation_tree = $"../../AnimationTree"
@onready var state_machine = animation_tree.get("parameters/playback")
var player_in_zone: bool
var target : CharacterBody2D
var enemy : CharacterBody2D
func Enter():
	player_in_zone = false
	target = get_tree().get_first_node_in_group("Player")
	enemy =  $"../.."
	collision = $"../../detection_zone/CollisionShape2D"
func Physics_update(delta):
	enemy.velocity = Vector2.ZERO
	update_animation_parameters(Vector2.ZERO)
	enemy.move_and_slide()
	pick_new_animation()
	if player_in_zone:
		transitioned.emit("Chase")
func update_animation_parameters(move_direction : Vector2):
	if(move_direction != Vector2.ZERO):
		animation_tree.set("parameters/Idle/blend_position", move_direction)
		animation_tree.set("parameters/Move/blend_position", move_direction)
func pick_new_animation():
	if(enemy.velocity != Vector2.ZERO):
		state_machine.travel("Move")
	else:
		state_machine.travel("Idle")
func _on_detection_zone_body_entered(body):
	if body.has_method("player"):
		player_in_zone = true
		target = body

