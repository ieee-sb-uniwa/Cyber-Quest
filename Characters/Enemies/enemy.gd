extends CharacterBody2D
class_name Enemy
@export var move_speed : float = 300
@export var acceleration : float = 7
@export var path_follow : PathFollow2D 
@export var hunting_target : CharacterBody2D 
var player_dead = false
func _physics_process(_delta):
	if !player_dead :
		$detection_zone/Circle.disabled = false
	else:
		$detection_zone/Circle.disabled = true
