extends Node2D
@onready var area: Area2D = $InteractionArea
@onready var terminal_sprite = $Sprite2D
@export var terminal_index: int = 0

func _ready():
	area.set_object_type("terminal")
	area.interaction_status = Global.INTERACTION_STATUS.AVAILABLE
	if terminal_index == 0:
		terminal_sprite.set_frame(0)
	elif terminal_index == 2:
		terminal_sprite.set_frame(2)
	elif terminal_index == 3:
		terminal_sprite.set_frame(3)

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
	get_tree().paused = true
	var password_ui = get_tree().current_scene.get_node("HUD/PasswordUI")
	password_ui.visible = true
	Global.can_pause_game = false
