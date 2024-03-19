extends CharacterBody2D
class_name Enemy

var speed = 100
var player_in_area = false
var player_dead = false
var player
var wander_time : float

func _ready():
	player_dead  = false
func randomize_wander():
	position += Vector2(randf_range(-1,1), randf_range(-1,1)).normalized()
	velocity += position * speed 
	wander_time = randf_range(1, 3)
func _physics_process(_delta):
	if !player_dead :
		$detetction_area/CollisionShape2D.disabled = false
		if player_in_area:
			position += (player.position - position) / speed
			$AnimatedSprite2D.play("move")
		else:
			$AnimatedSprite2D.play("idle")
	else:
		$detetction_area/CollisionShape2D.disabled = true;

func _on_detetction_area_body_entered(body):
	if body.has_method("player"):
		player_in_area = true
		player = body
		
func _on_detetction_area_body_exited(body):
	if body.has_method("player"):
		player_in_area = false
