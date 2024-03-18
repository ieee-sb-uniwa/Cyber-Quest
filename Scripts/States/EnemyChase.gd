extends State
class_name EnemyFollow

@export var enemy: CharacterBody2D
@export var mov_speed := 40.0
var player : CharacterBody2D

func Enter():
	pass
	player = get_tree().get_first_node_in_group("Player")

func  Physics_Update(_delta : float):
	var direction = player.global_position - enemy.global_position
	
	if direction.length() > 10:
		enemy.velocity = direction.normalized() * mov_speed
	else:
		enemy.velocity = Vector2()
	
	if direction.length() > 50:
		Transitioned.emit(self, "Idle")
		
