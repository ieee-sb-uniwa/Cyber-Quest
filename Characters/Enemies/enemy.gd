extends CharacterBody2D
class_name Enemy
@export var move_speed : float = 50
var player_in_area = false
var player_dead = false
var direction : Vector2

func _physics_process(_delta):
	"""
	if !player_dead :
		$detection_zone/CollisionShape2D.disabled = false
		if player_in_area:
			var direction = global_position.direction_to(player.global_position)
			velocity = direction * speed
			move_and_slide()
			#global_position += (player.global_position - global_position) / speed
			$AnimatedSprite2D.play("move")
		else:
			$AnimatedSprite2D.play("idle")
	else:
		$detection_zone/CollisionShape2D.disabled = true;
	"""
"""
func _on_detetction_area_body_entered(body):
	if body.has_method("player"):
		player_in_area = true
		player = body
		
func _on_detetction_area_body_exited(body):
	if body.has_method("player"):
		player_in_area = false

"""
