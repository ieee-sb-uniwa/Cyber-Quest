extends Node


var scenes: Dictionary = {
	"Main_Menu": preload("res://Menus/main_menu/Menu.tscn"),
	"Load_Menu": preload("res://Menus/main_menu/Load-Menu.tscn"),
	"Options_Menu": preload("res://Menus/main_menu/Options-Menu.tscn"),
	"Newgame_Menu": preload("res://Menus/main_menu/NewGame_Menu.tscn"),
	"Level_1_1": preload("res://Levels/Lvl1_1.tscn"),
	"Level_1_2": preload("res://Levels/Lvl1_2.tscn"),
	"Level_1_3": preload("res://Levels/Lvl1_3.tscn"),
	"Level_1_4": preload("res://Levels/Lvl1_4.tscn"),
	"Level_1_5": preload("res://Levels/Lvl1_5.tscn"),
	"Level_1_6": preload("res://Levels/Lvl1_6.tscn"),
}

var current_scene = null

func _ready() -> void:
	_open_scene("Main_Menu", -1)

func _open_scene(scene_name: String, target_index: int) -> void:
	assert(scene_name in scenes, "Scene '%s' not found!" % scene_name)
	Global.before_scene_change()
	Global.reset_variables()
	var new_scene = scenes[scene_name].instantiate()
	add_child(new_scene)
	if current_scene:
		current_scene.queue_free()
		current_scene = null
	current_scene = new_scene
	if (target_index > 0):
		PlayerData.level = target_index
	Global.save_game()


func on_new_game(player_names: Array, birthdates: Array) -> void:
	PlayerData.player_name_1 = player_names[0]
	PlayerData.birthdate_1 = birthdates[0]
	PlayerData.player_name_2 = player_names[1]
	PlayerData.birthdate_2 = birthdates[1]
	PlayerData.inv_slot = 0
	PlayerData.level = 11
	Global.isTutorial = true
	Global.lobby_doors_open = [true, false, true]
