extends CharacterBody2D
class_name Enemy
@export var move_speed : float = 300
@export var acceleration : float = 7
@export var path_follow : PathFollow2D 
@export var hunting_target : CharacterBody2D 
@onready var sprite : Sprite2D = $Sprite2D
@export var input_texture : Texture2D 
@export var spriteRows : int  
@export var spriteColumns : int  
var player_dead = false

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
func Enemy():
	pass
