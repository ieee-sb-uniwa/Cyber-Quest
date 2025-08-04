extends CharacterBody2D
class_name Enemy_nav
#These values affect animation logic
@onready var sprite : Sprite2D = $Sprite2D
@onready var animation_tree = $"AnimationTree"
@onready var nav_agent = $'NavigationAgent2D' as NavigationAgent2D
@onready var state_machine = animation_tree.get("parameters/playback")
#All of these have to do with movement and enemy behavior
@export var move_speed : float = 75
@export var acceleration : float = 7
@export var patrolling_rooms : Array[Area2D] = [] 
var current_path_index := 0
var hunting_targets :  Array[Node2D] = []
#@export var player_in_zone: bool
#@export var player_visible: bool
@export var starting_direction : Vector2 = Vector2(0, 1)
var player_dead = false
var hit_pos
var enemy_direction
#These are for enemy textures
@export var input_texture : Texture2D 
@export var spriteRows : int  
@export var spriteColumns : int  


func _ready(): 
	sprite.texture = input_texture
	sprite.vframes = spriteRows
	sprite.hframes = spriteColumns
	update_animation_parameters(starting_direction)
	print(nav_agent.name)

func _physics_process(_delta):
	Aim()
	if !player_dead :
		$chase_range/Circle.disabled = false
	else:
		$chase_range/Circle.disabled = true
	enemy_direction = getCardinalDirection()
	update_animation_parameters(enemy_direction)
	pick_new_animation()
#The following function rounds the enemies direction to one of the cardinal directions
#to simplify enemy animation handling
func getCardinalDirection() -> Vector2:
	var test_direction = round(self.get_global_rotation_degrees())
	if(test_direction<0):
		test_direction+= 360
	if (test_direction>315 || test_direction<46):
		return Vector2.RIGHT
	elif (test_direction>45 && test_direction<136):
		return Vector2.DOWN
	elif (test_direction>135 && test_direction<226):
		return Vector2.LEFT
	elif (test_direction>225 && test_direction<316):
		return Vector2.UP
	return test_direction #If this is called sth went wrong

#Used to identify objects of the enemy class
func Enemy():
	pass
#Aim  checks if there are walls between the enemy and the player
#If we want to not be able to see the player in a box make it so hides-in-boxes changes the players collision
#layer to anything but 3.
func Aim():
	var _space_State = get_world_2d().direct_space_state
	#var query = PhysicsRayQueryParameters2D.create(global_position, hunting_target.global_position, 0xF,[self])
	#query.collide_with_areas=false
	#var result = space_State.intersect_ray(query)
	#if result:
		#hit_pos = result.position
		#if result.collider.name == "Player" && hunting_target.collision_layer!=30:
			#rotation = (target.position - position).angle()
			#player_visible = true
		#else :
	#player_visible = false

#Cone = Detection zone
#Basically starts chasing player when he enters the cone
#Stops when player leaves the circle
func _on_detection_zone_body_entered(body: Node2D) -> void:
	if body.has_method("player") :
		hunting_targets.append(body)

func _on_detection_zone_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		hunting_targets.erase(body)
	
#chase range= circle
#func _on_chase_range_body_entered(body: Node2D) -> void:
	#if body.has_method("player"):
		#player_in_zone = true
		##player_in_cone = false
#
#
#func _on_chase_range_body_exited(body: Node2D) -> void:
	#if body.has_method("player"):
		#player_in_zone=false
		##player_in_cone= false
		
func update_animation_parameters(move_direction : Vector2):
	if(move_direction != Vector2.ZERO):
		animation_tree.set("parameters/Idle/blend_position", move_direction)
		animation_tree.set("parameters/Move/blend_position", move_direction)
		

func pick_new_animation():
	if(self.velocity != Vector2.ZERO):
		state_machine.travel("Move")
	else:
		state_machine.travel("Idle")
