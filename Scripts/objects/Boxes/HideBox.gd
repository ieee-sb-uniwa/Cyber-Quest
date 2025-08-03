extends StaticBody2D
@onready var box_area: Area2D = $InteractionArea
@onready var player: Node2D = $"../../Player"  
var curr_player: Node2D
@onready var box_sprite: Sprite2D = $Box_Sprite  

var is_player_hidden = false 

func _process(_delta):
	box_area.set_object_type("box")
	if Input.is_action_just_pressed("Interact") and (box_area.has_overlapping_bodies() or is_player_hidden):
	if (Input.is_action_just_pressed("Interact_p1") || Input.is_action_just_pressed("Interact_p2")) and (box_area.has_overlapping_bodies() or is_player_hidden):
		var bodies = box_area.get_overlapping_bodies()
		for body in bodies:
			if body.has_method("player"):
				curr_player = body
		toggle_hide()

func toggle_hide():
	is_player_hidden = !is_player_hidden  # Toggle the hidden state
	player.visible = !is_player_hidden  	 # Hide/Unhide player
	curr_player.visible = !is_player_hidden  	 # Hide/Unhide player
	if is_player_hidden: 
		box_area.set_label("Press [E] to unhide")
		player.set_collision_layer_value(30,true)
		player.set_collision_layer_value(1,false)
		Global.move_speed = 0
		box_area.set_label("Press [E] or [.] to unhide")
		curr_player.set_collision_layer_value(30,true)
		curr_player.set_collision_layer_value(1,false)
		curr_player.set_collision_layer_value(2,false)
		curr_player.move_speed = 0
		box_sprite.set_frame(0)
	else: 
		box_area.set_label("Press [E] to hide")
		set_collision_layer_value(1,true)
		set_collision_layer_value(30,false)
		Global.move_speed = 150
		box_area.set_label("Press [E] or [.] to hide")
		curr_player.set_collision_layer_value(1,true)
		curr_player.set_collision_layer_value(2,true)
		curr_player.set_collision_layer_value(30,false)
		curr_player.move_speed = Global.move_speed
		box_sprite.set_frame(1) 
