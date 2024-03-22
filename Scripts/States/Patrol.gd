class_name Patrol
extends State
var animated_sprite 
var collision 
var player_in_zone: bool
var player
var enemy
func Enter():
	player_in_zone = false
	player = get_tree().get_first_node_in_group("Player")
	animated_sprite = $"../../AnimatedSprite2D"
	enemy =  $"../.."
	collision = $"../../detection_zone/CollisionShape2D"

func Physics_update(_delta):
	animated_sprite.play("idle")
	if player_in_zone:
		transitioned.emit("Chase")
func _on_detection_zone_body_entered(body):
	if body.has_method("player"):
		player_in_zone = true
		player = body

