extends Camera2D

@export var player1: Node2D
@export var player2: Node2D
@export var follow_speed: float = 5.0
@export var offset_margin: float = 200.0  # How far from the center players can be

func assign_player(player_num: int, node: Node2D) -> void:
	if player_num == 1:
		player1 = node
	elif player_num == 2:
		player2 = node

func _process(delta: float) -> void:
	if not player1 or not player2:
		return
	# Midpoint between players
	var center_pos = (player1.global_position + player2.global_position) * 0.5
	
	# Optional: Maintain margin before adjusting camera (avoids jitter)
	var distance = player1.global_position.distance_to(player2.global_position)
	if distance > offset_margin:
		global_position = global_position.lerp(center_pos, delta * follow_speed)
	else:
		# Softly ease towards midpoint even if within margin
		global_position = global_position.lerp(center_pos, delta * (follow_speed * 0.3))
