extends Node2D
@onready var area: Area2D = $InteractionArea

func _ready():
	area.set_object_type("terminal")
	area.interaction_status = Global.INTERACTION_STATUS.AVAILABLE

func _process(_delta):
	# Check if this is the closest interaction area
	var closest_area = InteractionManager.get_closest_area()
	if closest_area != area:
		return
		
	var bodies = area.get_overlapping_bodies()
	# Only check input if there is a body inside area
	if bodies.size() == 0: 
		return
	for body in bodies:
			if !body.is_in_group("Player"):
				return
			if (Global.player_interacts("Interact_p1", "MainPlayer", body) or Global.player_interacts("Interact_p2", "SecondPlayer", body)):
				if Global.can_access_terminal():
					_open_terminal()
				else:
					area.set_label("Μάζεψε όλα τα μπλοκ για να το ανοίξεις!")
					
func _open_terminal():
	var tree := get_tree()
	if tree == null:
		return
	tree.paused = true
	var password_ui = tree.current_scene.get_node("HUD/PasswordUI")
	password_ui.visible = true
	Global.can_pause_game = false
