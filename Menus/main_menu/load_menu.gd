extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	var canLoad = Global.saveData.load_game()
	if canLoad:
		$CenterVbox/VBoxContainer/N1.text = "Players: " + PlayerData.player_name_1 + " & " + PlayerData.player_name_2
	$VBoxContainer2/BacktoMenu.grab_focus();

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_backto_menu_pressed():
	Controller._open_scene("Main_Menu",-1)

func _on_n_1_pressed() -> void:
	var level_num = int(PlayerData.level / 10.0)
	var scene_num = PlayerData.level % 10
	# Clean up globals before switching to level scene
	Global.before_scene_change()
	AudioPlayer.stop_clear()	# Use before loading level to stop menu music
	Controller._open_scene("Level_%d_%d" % [level_num, scene_num], PlayerData.level)
	print("Level_%d_%d" % [level_num, scene_num])
	print(PlayerData.level)
	print(PlayerData.inv_slot)

#! OTHER SAVE FILES -> FUTURE REFERENCE
func _on_n_2_pressed() -> void:
	pass # Replace with function body.

func _on_n_3_pressed() -> void:
	pass # Replace with function body.

func _on_resume_playing_pressed() -> void:
	$"../InventoryGUI".show()	
	$"../../".show()
	queue_free()	# Destroys the instanced load node
