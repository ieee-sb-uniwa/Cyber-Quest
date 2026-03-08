extends StaticBody2D
@onready var box_area: Area2D = $InteractionArea
var curr_player: Node2D
@onready var box_sprite: Sprite2D = $Box_Sprite  
var is_player_hidden = false 

func _ready():
	box_area.set_object_type("hidebox")
	box_area.interaction_status = Global.INTERACTION_STATUS.AVAILABLE
	box_sprite.set_frame(1)  # Set to "unhidden" frame initially

func _process(_delta):
	# Check if this is the closest interaction area
	var closest_area = InteractionManager.get_closest_area()
	if closest_area != box_area:
		return
		
	var bodies = box_area.get_overlapping_bodies()
	# Only check input if there is a body inside area
	if bodies.size() == 0: 
		return
	for body in bodies:
			if body.is_in_group("Player") and not is_player_hidden:
				curr_player = body
	if (Global.player_interacts("Interact_p1", "MainPlayer", curr_player) || Global.player_interacts("Interact_p2", "SecondPlayer", curr_player)):
		toggle_hide()

func toggle_hide():
	is_player_hidden = !is_player_hidden  		 # Toggle the hidden state
	curr_player.visible = !is_player_hidden  	 # Hide/Unhide player
	if is_player_hidden:
		curr_player.hide_holder = self 
		box_area.interaction_status = Global.INTERACTION_STATUS.OCCUPIED
		curr_player.set_collision_layer_value(30,true)
		curr_player.set_collision_layer_value(2,false)
		curr_player.is_hidden = true
		curr_player.move_speed = 0
		box_sprite.set_frame(0)
	else:
		curr_player.hide_holder = null 
		box_area.interaction_status = Global.INTERACTION_STATUS.AVAILABLE
		curr_player.set_collision_layer_value(2,true)
		curr_player.set_collision_layer_value(30,false)
		curr_player.is_hidden = false
		curr_player.move_speed = Global.move_speed
		box_sprite.set_frame(1)