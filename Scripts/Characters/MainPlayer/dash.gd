extends Node2D

@export var player:CharacterBody2D
@export var dash_movement:float = 700
@export var dash_duration:float = 0.5
@export var cooldown_time:float = 1.0

var _is_dashing = false
var _cooldown_timer = 0.0
var _dash_timer = 0.0
var _direction := Vector2.ZERO
var direction_dict = {Global.MOVE_ORIENTATION.LEFT:Vector2(-1,0),Global.MOVE_ORIENTATION.UP:Vector2(0,-1), Global.MOVE_ORIENTATION.RIGHT:Vector2(1,0), Global.MOVE_ORIENTATION.DOWN:Vector2(0,1)}
		
func _physics_process(_delta):
	if !player:
		return
	if _cooldown_timer > 0:
		_cooldown_timer -= _delta
	if _is_dashing:
		_dash_timer -= _delta
		if _dash_timer <= 0:
			player.movement_enabled = true
			_is_dashing = false
	if Input.is_action_just_pressed("Dash_p"+str(player.playerNum)):
		start_dash()
			
func start_dash():
	if _cooldown_timer <= 0 and not _is_dashing:
		print("dashing...")
		var input_direction:Vector2 = player.get_movement_inputs()
		var dash_calculation
		if input_direction.x!=0 || input_direction.y != 0:
			dash_calculation = input_direction.normalized() * dash_movement
		else:
			dash_calculation = direction_dict[player.move_orientation].normalized() * dash_movement
		_is_dashing = true
		_dash_timer = dash_duration
		_cooldown_timer = cooldown_time
		player.velocity = dash_calculation
		player.movement_enabled = false
		
func apply_dash_velocity():
	if _is_dashing:
		return _direction * dash_movement
	return Vector2.ZERO
	
func is_dashing() -> bool:
	return _is_dashing
