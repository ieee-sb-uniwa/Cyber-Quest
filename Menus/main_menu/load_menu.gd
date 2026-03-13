extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	var canLoad = Global.saveData.load_game()
	if canLoad:
		$CenterVbox/VBoxContainer/N1.text = "Players: " + PlayerData.player_name_1 + " & " + PlayerData.player_name_2
	$VBoxContainer2/BacktoMenu.grab_focus();

func on_scene_shown():
	#Called every time it enters from pool. Important, we might need to change some _ready() functions.
	$VBoxContainer2/ResumePlaying.hide()
	print("I was called")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_backto_menu_pressed():
	Controller._open_menu_scene("Main_Menu")

func _on_resume_playing_pressed() -> void:
	# Used when opened from Pause Menu
	var lvl = Controller.current_scene
	if lvl:
		lvl.show()
	
	# Find InventoryGUI in the level if possible
	var inv = lvl.get_node_or_null("HUD/InventoryGUI")
	if inv:
		inv.show()
	
	# Find PauseMenu in the level
	var pause_menu = lvl.get_node_or_null("HUD/PauseHud/Pause_menu")
	if pause_menu:
		pause_menu.show()
		
	# Move ourselves to pool
	Controller._move_to_pool(self)

func _on_n_1_pressed() -> void:
	var level_num = int(PlayerData.level / 10.0)
	var scene_num = PlayerData.level % 10
	# Clean up globals before switching to level scene
	Global.before_scene_change()
	AudioPlayer.stop_clear()	# Use before loading level to stop menu music
	if (level_num!=0):
		Controller._open_scene("Level_%d_%d" % [level_num, scene_num], PlayerData.level)
	else:
		PlayerData.level=11
		Controller._open_scene("Level_1_1",PlayerData.level)
	print("Level_%d_%d" % [level_num, scene_num])
	print(PlayerData.level)
	print(PlayerData.inv_slot)

#! OTHER SAVE FILES -> FUTURE REFERENCE
func _on_n_2_pressed() -> void:
	pass # Replace with function body.

func _on_n_3_pressed() -> void:
	pass # Replace with function body.
