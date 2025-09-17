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
	# print("Chasing")
	#enemy.player_in_zone = true
	#enemy.player_in_cone = true
	#enemy.player_visible = true
	generate_path()

func Physics_update(_delta: float) -> void:
	if(enemy.hunting_target == null):
		return
	var direction_to_player = (enemy.hunting_target.global_position - enemy.global_position).normalized()
	enemy.rotation = direction_to_player.angle()  # Rotate the enemy to face the player
	enemy.sprite.set_global_rotation(0)
	nav_test()
	#Rotate cone 
	#conicalDetectionArea.rotation = enemy.rotation
	if enemy.hunting_target.visible==false:
		transitioned.emit("Patrol")
	if !enemy.player_in_zone || !enemy.player_visible:
		# print("Stop chasing")
		transitioned.emit("Patrol")

func generate_path() -> void:
	if enemy.hunting_target != null:
		nav_agent.target_position = enemy.hunting_target.position

func nav_test():
	nav_agent.target_position = enemy.hunting_target.global_position
	var current_position= enemy.global_position
	var next_path_position = nav_agent.get_next_path_position()
	var new_velocity = current_position.direction_to(next_path_position) * enemy.move_speed
	if nav_agent.avoidance_enabled:
		nav_agent.set_velocity(new_velocity)
	else: 
		_on_navigation_agent_2d_velocity_computed(new_velocity)
	enemy.move_and_slide()

func _on_timer_timeout():
	generate_path()


func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	enemy.velocity=safe_velocity
