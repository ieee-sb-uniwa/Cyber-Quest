extends Camera2D

@export var player1: Node2D
@export var player2: Node2D
@export var follow_speed: float = 5.0
@export var offset_margin: float = 200.0  # How far from the center players can be
var target_position: Vector2 = Vector2.ZERO
var is_cam_enabled :bool = true

func _ready() -> void:
	SpawnManager.camera_asset = self
func assign_player(player_num: int, node: Node2D) -> void:
	if player_num == 1:
		player1 = node
	elif player_num == 2:
		player2 = node

func get_camera_bounds() -> Rect2:
	var screen_size = get_viewport_rect().size
	var visible_size = screen_size * self.zoom
	var top_left = global_position - visible_size * 0.5
	return Rect2(top_left, visible_size)
	
func clamp_player_position(player: Node2D) -> void:
	var bounds = get_camera_bounds()
	var sprite_size = Vector2(32, 32)  # adjust to your player's actual size in world units

	# Clamp player's position, offsetting so sprite won't clip out of screen
	var min_pos = bounds.position + sprite_size * 0.5
	var max_pos = bounds.position + bounds.size - sprite_size * 0.5
	player.global_position = player.global_position.clamp(min_pos, max_pos)

func _process(delta: float) -> void:
	if not player1 or not player2:
		return
	# Midpoint between players
	var center_pos = (player1.global_position + player2.global_position) * 0.5
	if !is_cam_enabled && self.position.distance_to(center_pos)<5:
		is_cam_enabled = true
	
	# Optional: Maintain margin before adjusting camera (avoids jitter)
	var distance = player1.global_position.distance_to(player2.global_position)
	if distance > offset_margin:
		global_position = global_position.lerp(center_pos, delta * follow_speed)
	else:
		# Softly ease towards midpoint even if within margin
		global_position = global_position.lerp(center_pos, delta * (follow_speed * 0.3))
		
	if is_cam_enabled:
		clamp_player_position(player1)
		clamp_player_position(player2)
