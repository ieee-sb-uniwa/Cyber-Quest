class_name Chase
extends State
var animated_sprite 
var collision
var enemy 
var player 
var player_in_zone : bool
func Enter():
	player_in_zone = true
	player = get_tree().get_first_node_in_group("Player")
	enemy = $"../.."
	animated_sprite = $"../../AnimatedSprite2D"
	collision = $"../../detection_zone/CollisionShape2D"
func Physics_update(_delta):
	animated_sprite.play("move")
	#enemy.position += (player.position - enemy.position) / enemy.move_speed
	var direction = enemy.global_position.direction_to(player.global_position)
	enemy.velocity = direction * enemy.move_speed
	enemy.move_and_slide()
	if !player_in_zone:
		transitioned.emit("Patrol")
func _on_detection_zone_body_exited(body):
	if body.has_method("player"):
		player_in_zone=false



