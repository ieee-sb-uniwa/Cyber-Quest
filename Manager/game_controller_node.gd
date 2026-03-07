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
var scene_pool: Node = null
var pooled_scenes: Dictionary = {}

func _ready() -> void:
	scene_pool = Node.new()
	scene_pool.name = "ScenePool"
	add_child(scene_pool)
	# Initially disable the pool
	scene_pool.process_mode = PROCESS_MODE_DISABLED
	_open_scene("Main_Menu", -1)


func _get_scene_from_pool(scene_name: String) -> Node:
	if scene_name in pooled_scenes:
		var scene = pooled_scenes[scene_name]
		scene_pool.remove_child(scene)
		pooled_scenes.erase(scene_name)
		return scene
	var new_scene = scenes[scene_name].instantiate()
	new_scene.set_meta("scene_name", scene_name)
	return new_scene


func _move_to_pool(scene: Node) -> void:
	if scene.get_parent() != null:
		scene.get_parent().remove_child(scene)
	
	var scene_name = scene.get_meta("scene_name", "")
	if scene_name != "":
		scene_pool.add_child(scene)
		pooled_scenes[scene_name] = scene
		_recursive_hide_and_disable(scene)
	else:
		scene.queue_free()


func _recursive_hide_and_disable(node: Node) -> void:
	node.process_mode = PROCESS_MODE_DISABLED
	if node is CanvasItem:
		node.visible = false
		node.set_deferred("visible", false) # Redundant but safe
		if node is Control:
			node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if node is CanvasLayer:
		node.visible = false
	for child in node.get_children():
		_recursive_hide_and_disable(child)


func _recursive_show_and_enable(node: Node) -> void:
	node.process_mode = PROCESS_MODE_INHERIT
	if node is CanvasItem:
		node.visible = true
		if node is Control:
			# This is tricky as we don't know the original filter. 
			# Most of our buttons/controls use MOUSE_FILTER_STOP or PASS.
			# But if we don't restore it, they won't be clickable.
			# For now, let's assume default for Control is STOP if it was ignored.
			node.mouse_filter = Control.MOUSE_FILTER_STOP
	if node is CanvasLayer:
		node.visible = true
	for child in node.get_children():
		_recursive_show_and_enable(child)


func _open_menu_scene(scene_name: String) -> void:
	assert(scene_name in scenes, "Scene '%s' not found!" % scene_name)
	
	if current_scene:
		_move_to_pool(current_scene)
		current_scene = null
		
	var new_scene = _get_scene_from_pool(scene_name)
	add_child(new_scene)
	_recursive_show_and_enable(new_scene)
	current_scene = new_scene


func _open_scene(scene_name: String, target_index: int) -> void:
	assert(scene_name in scenes, "Scene '%s' not found!" % scene_name)
	Global.before_scene_change()
	Global.reset_variables()
	
	if current_scene:
		_move_to_pool(current_scene)
		current_scene = null
		
	var new_scene = _get_scene_from_pool(scene_name)
	add_child(new_scene)
	_recursive_show_and_enable(new_scene)
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
