extends StaticBody2D
@onready var box_area: Area2D = $InteractionArea
var curr_player: Node2D
@onready var box_sprite: Sprite2D = $Box_Sprite  
var is_player_hidden = false 

func _process(_delta):
	box_area.set_object_type("box")
	var bodies = box_area.get_overlapping_bodies()
	# Only check input if there is a body inside area
	if bodies.size() == 0: 
		return
	for body in bodies:
			if body.is_in_group("Player") and not is_player_hidden:
				curr_player = body
	if (player_interacts("Interact_p1", "MainPlayer") || player_interacts("Interact_p2", "SecondPlayer")):
		toggle_hide()

func player_interacts(interact_button: String, player_group: String) -> bool:
	return Input.is_action_just_pressed(interact_button) && curr_player.is_in_group(player_group)

func toggle_hide():
	is_player_hidden = !is_player_hidden  		 # Toggle the hidden state
	curr_player.visible = !is_player_hidden  	 # Hide/Unhide player
	if is_player_hidden: 
		box_area.set_label("Press [E] or [.] to unhide")
		box_area.interaction_status = Global.INTERACTION_STATUS.OCCUPIED
		# !!!!! ΕΔΩ ΚΑΤΙ ΚΑΝΕ ΓΙΑΤΙ ΧΑΛΑΝΕ ΓΕΝΙΚΑ ΤΑ COLLISION LAYERS ΤΟΥ ΠΑΙΧΤΗ KAI O ENEMY AKOMA TON ANIXNEYEI
		curr_player.set_collision_layer_value(30,true)
		curr_player.set_collision_layer_value(2,false)
		curr_player.is_hidden = true
		curr_player.move_speed = 0
		box_sprite.set_frame(0)
	else: 
		box_area.set_label("Press [E] or [.] to hide")
		# !!!!! ΕΔΩ ΚΑΤΙ ΚΑΝΕ ΓΙΑΤΙ ΧΑΛΑΝΕ ΓΕΝΙΚΑ ΤΑ COLLISION LAYERS ΤΟΥ ΠΑΙΧΤΗ
		box_area.interaction_status = Global.INTERACTION_STATUS.AVAILABLE
		curr_player.set_collision_layer_value(2,true)
		curr_player.set_collision_layer_value(30,false)
		curr_player.is_hidden = false
		curr_player.move_speed = Global.move_speed
		box_sprite.set_frame(1)
