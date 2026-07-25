extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	var canLoad = Global.saveData.load_game()
	if canLoad:
		$SaveFiles/Profiles/N1.text = PlayerData.player_name_1 + " & " + PlayerData.player_name_2
	$Buttons/BacktoMenu.grab_focus();
	if $SaveFiles/Profiles/N2.text == "":
		$SaveFiles/Profiles/P2.hide()
		$SaveFiles/Profiles/N2.hide()
	if $SaveFiles/Profiles/N3.text == "":
		$SaveFiles/Profiles/P3.hide()
		$SaveFiles/Profiles/N3.hide()

func _on_backto_menu_pressed():
	get_tree().call_deferred("change_scene_to_file", "res://Menus/main_menu/Menu.tscn")

func _on_n_1_pressed() -> void:
	var level_num = int(PlayerData.level / 10.0)
	var scene_num = PlayerData.level % 10
	var level_path = "res://Levels/Lvl" + str(level_num, '_', scene_num, ".tscn")
	# Clean up globals before switching to level scene
	Global.before_scene_change()
	AudioPlayer.stop_clear()	# Use before loading level to stop menu music
	get_tree().change_scene_to_file(level_path)

#! OTHER SAVE FILES -> FUTURE REFERENCE
func _on_n_2_pressed() -> void:
	pass # Replace with function body.

func _on_n_3_pressed() -> void:
	pass # Replace with function body.

func _on_resume_playing_pressed() -> void:
	$"../InventoryGUI".show()	
	$"../../".show()
	queue_free()	# Destroys the instanced load node
