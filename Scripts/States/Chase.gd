class_name Chase
extends State
@onready var sprite : Sprite2D = $"../../Sprite2D"
@onready var enemy : CharacterBody2D = $"../.."
@export var starting_direction : Vector2 = Vector2(0, 1)
@onready var animation_tree = $"../../AnimationTree"
@onready var state_machine = animation_tree.get("parameters/playback")
@onready var conicalDetectionArea: CollisionPolygon2D = $"../../detection_zone/Cone"
@onready var circularDetectionArea: CollisionShape2D = $"../../chase_range/Circle"
@onready var nav_agent: NavigationAgent2D = $"../../NavigationAgent2D"


func Enter():
	enemy.player_in_zone = true
	enemy.player_in_cone = true
	enemy.player_visible = true





func Physics_update(_delta: float) -> void:
	nav_agent.target_position= enemy.hunting_target.global_position
	enemy.velocity= enemy.global_position.direction_to(nav_agent.get_next_path_position()) * enemy.move_speed
	enemy.move_and_slide()
	#var direction = (nav_agent.get_next_path_position() - enemy.position).normalized()
	#enemy.velocity = enemy.velocity.lerp(direction * enemy.move_speed,enemy.acceleration * _delta)
	#Rotate cone 
	#conicalDetectionArea.rotation = direction.angle()
	if !enemy.player_in_zone || !enemy.player_visible:
		transitioned.emit("Patrol")

func generate_path() -> void:
	if enemy.hunting_target != null:
		nav_agent.target_position = enemy.hunting_target.position


func _on_timer_timeout():
	generate_path()
