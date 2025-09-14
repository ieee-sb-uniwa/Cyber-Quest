extends Node2D
@onready var area: Area2D = $InteractionArea

func _ready():
	area.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.has_method("player"):
		print("Player detected")
		print(body)
		if (Input.is_action_just_pressed("Interact_p1")):
			_open_terminal()

func _process(_delta):
	var bodies = area.get_overlapping_bodies()
	# Only check input if there is a body inside area
	if bodies.size() == 0: 
		return
	for body in bodies:
			if body.is_in_group("Player"):
				if (Global.player_interacts("Interact_p1", "MainPlayer", body) or Global.player_interacts("Interact_p2", "SecondPlayer", body)):
					_open_terminal()
					
func _open_terminal():
	get_tree().change_scene_to_file("res://PasswordUI/new/ctrl.tscn")