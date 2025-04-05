extends StaticBody2D

@onready var box_area: Area2D = $InteractionArea
@onready var player: Node2D = $"../../Player"  
@onready var box_sprite: Sprite2D = $Box_Sprite  

var is_player_hidden = false 

func _process(_delta):
	if Input.is_action_just_pressed("Interact") and (box_area.has_overlapping_bodies() or is_player_hidden):
		_toggle_hide()

func _toggle_hide():
	is_player_hidden = !is_player_hidden  # Toggle the hidden state
	player.visible = !is_player_hidden  # Hide/Unhide player
	if is_player_hidden: 
		print("player hidden")
		box_area.set_label("Press [E] to unhide")
		player.set_collision_layer_value(30,true)
		player.set_collision_layer_value(1,false)
		Global.move_speed = 0
		box_sprite.set_frame(0)
	else: 
		print("player visible")
		box_area.set_label("Press [E] to hide")
		set_collision_layer_value(1,true)
		set_collision_layer_value(30,false)
		Global.move_speed = 150
		box_sprite.set_frame(1) 
