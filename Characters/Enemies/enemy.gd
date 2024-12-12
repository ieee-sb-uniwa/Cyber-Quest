extends CharacterBody2D
class_name Enemy
@onready var sprite : Sprite2D = $Sprite2D

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

var player_dead = false
var hit_pos
var target

func _ready():
	sprite.texture = input_texture
	sprite.vframes = spriteRows
	sprite.hframes = spriteColumns
	hunting_target = $"../../Player"
func _physics_process(_delta):
	if !player_dead :
		$chase_range/Circle.disabled = false
	else:
		$chase_range/Circle.disabled = true
	if target :
		Aim()
	
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
