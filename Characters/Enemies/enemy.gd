extends CharacterBody2D
class_name Enemy
@export var move_speed : float = 50
var player_dead = false
func _physics_process(_delta):
	if !player_dead :
		$detection_zone/CollisionShape2D.disabled = false
	else:
		$detection_zone/CollisionShape2D.disabled = true;
