extends CharacterBody2D
class_name Enemy
@onready var sprite : Sprite2D = $Sprite2D
@onready var animation_tree = $"AnimationTree"
@onready var state_machine = animation_tree.get("parameters/playback")

@export var move_speed : float = 300
@export var acceleration : float = 7
@export var path_follow : PathFollow2D 
@export var hunting_target : CharacterBody2D 
@export var input_texture : Texture2D 
@export var spriteRows : int  
@export var spriteColumns : int  
@export var player_in_zone: bool
@export var player_in_cone: bool
@export var player_visible: bool
@export var starting_direction : Vector2 = Vector2(0, 1)


var player_dead = false
var hit_pos
var target
var direction

func _ready():
	sprite.texture = input_texture
	sprite.vframes = spriteRows
	sprite.hframes = spriteColumns
	hunting_target = $"../../Player"
	update_animation_parameters(starting_direction)

func _physics_process(_delta):
	direction = getCardinalDirection()
	update_animation_parameters(direction)
	if(direction== Vector2.LEFT):
		sprite.flip_v= true
		sprite.flip_h=true
	else:
		sprite.flip_v= false
		sprite.flip_h= false
	velocity = direction.normalized() * move_speed
	move_and_slide()
	if !player_dead :
		$chase_range/Circle.disabled = false
	else:
		$chase_range/Circle.disabled = true
	if target :
		Aim()

func getCardinalDirection() -> Vector2:
	var test_direction = round(self.get_global_rotation_degrees())
	if(test_direction<0):
		test_direction+= 360
	print(test_direction)
	if (test_direction>315 || test_direction<46):
		print("I'm moving right")
		return Vector2.RIGHT
	elif (test_direction>45 && test_direction<136):
		print("I'm moving down")
		return Vector2.DOWN
	elif (test_direction>135 && test_direction<226):
		print("I'm moving left")
		return Vector2.LEFT
	elif (test_direction>225 && test_direction<316):
		print("I'm moving up")
		return Vector2.UP
	return test_direction #If this is called sth went wrong

#Used to identify objects of the enemy class
func Enemy():
	pass
#Aim  checks if there are walls between the enemy and the player
func Aim():
	var space_State = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(position, hunting_target.position, 3, [self])
	var result = space_State.intersect_ray(query)
	if result:
		hit_pos = result.position
		if result.collider.name == "Player":
			rotation = (target.position - position).angle()
			player_visible = true
		else :
			player_visible = false
#Cone = Detection zone
#Basically starts chasing player when he enters the cone
#Stops when player leaves the circle
func _on_detection_zone_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_zone = true
		player_in_cone = true
		hunting_target = body
	if target:
		return
	target = body

func _on_detection_zone_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_zone= true
		player_in_cone= false
	if body == target:
		target = null
	
#chase range= circle
func _on_chase_range_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_zone = true
		player_in_cone = false


func _on_chase_range_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_zone=false
		player_in_cone= false
		
func update_animation_parameters(move_direction : Vector2):
	if(move_direction != Vector2.ZERO):
		animation_tree.set("parameters/Idle/blend_position", move_direction)
		animation_tree.set("parameters/Move/blend_position", move_direction)
		
func pick_new_animation():
	if(self.velocity != Vector2.ZERO):
		state_machine.travel("Move")
	else:
		state_machine.travel("Idle")
