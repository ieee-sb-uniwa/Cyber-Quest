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
	# Return a Scene from Waiting to main leaf
	if scene_name in pooled_scenes and pooled_scenes[scene_name].size() > 0:
		var scene = pooled_scenes[scene_name].pop_back()  # retrieve
		scene_pool.remove_child(scene)
		_recursive_show_and_enable(scene)
		return scene
	# Nothing in pool, instantiate fresh
	var new_scene = scenes[scene_name].instantiate()
	new_scene.set_meta("scene_name", scene_name)
	return new_scene


func _move_to_pool(scene: Node) -> void:
	# Removes old scene from visible Controller Children and Moves to Pool/Waiting area
	if scene.get_parent() != null:
		scene.get_parent().remove_child(scene)

	var scene_name = scene.get_meta("scene_name", "")
	if scene_name != "":
		# If we don't have this scene in the pool yet, add it
		if scene_name not in pooled_scenes:
			pooled_scenes[scene_name] = []
			pooled_scenes[scene_name].append(scene)
			scene_pool.add_child(scene)
			_recursive_hide_and_disable(scene)
		else:

			if scene not in pooled_scenes[scene_name]:

				scene.queue_free()
			else:

				if scene.get_parent() != scene_pool:
					scene_pool.add_child(scene)
				_recursive_hide_and_disable(scene)
	else:
		scene.queue_free()


func _recursive_hide_and_disable(node: Node) -> void:
	node.process_mode = PROCESS_MODE_DISABLED
	if node is CanvasItem:
		node.visible = false

	if node is CanvasLayer:
		node.visible = false
		node.hide() # Extra insurance for CanvasLayers

	for child in node.get_children():
		_recursive_hide_and_disable(child)


func _recursive_show_and_enable(node: Node) -> void:
	# Skip nodes that should stay hidden by design
	if node.is_in_group("persist_hidden"):
		return

	node.process_mode = PROCESS_MODE_INHERIT
	if node is CanvasItem:
		node.visible = true

	if node is CanvasLayer:
		node.visible = true
		node.show()

	for child in node.get_children():
		_recursive_show_and_enable(child)


func _open_menu_scene(scene_name: String) -> void:
	# Usable for Scenes that don't require global funcs/vars
	assert(scene_name in scenes, "Scene '%s' not found!" % scene_name)
	
	if get_tree().paused:
		get_tree().paused = false
	
	if current_scene:
		_move_to_pool(current_scene)
		current_scene = null
		
	var new_scene = _get_scene_from_pool(scene_name)
	if new_scene.get_parent() != self:
		add_child(new_scene)
	_recursive_show_and_enable(new_scene)
	current_scene = new_scene

	# This will make sure we can trigger _ready type logic on scene reentry
	if new_scene.has_method("on_scene_shown"):
		new_scene.on_scene_shown()
	
	# Fix resolution/scaling issues after scene change
	_ensure_proper_scaling() # DOESNT WORK YET

func _open_overlay_menu(scene_name: String) -> Node:
	print(get_tree_string_pretty())
	assert(scene_name in scenes, "Scene '%s' not found!" % scene_name)
	var new_scene = _get_scene_from_pool(scene_name)
	if new_scene.get_parent() != self:
		add_child(new_scene)
	_recursive_show_and_enable(new_scene)
	
	if new_scene.has_method("on_scene_shown"):
		new_scene.on_scene_shown()
	
	_ensure_proper_scaling()
	return new_scene

	
func _test_all_visible(node: Node) -> void:
	if(node.get_child_count()>0):
		for i in node.get_children():
			_test_all_visible(i)
	print(node.visible == false)

func _open_scene(scene_name: String, target_index: int) -> void:
	# Main way to change scenes, interacts with Global.
	assert(scene_name in scenes, "Scene '%s' not found!" % scene_name)
	Global.before_scene_change()
	Global.reset_variables()
	
	if current_scene:
		_move_to_pool(current_scene)
		current_scene = null
		
	var new_scene = _get_scene_from_pool(scene_name)
	if new_scene.get_parent() != self:
		add_child(new_scene)
	_recursive_show_and_enable(new_scene)
	current_scene = new_scene
	
	if new_scene.has_method("on_scene_shown"):
		new_scene.on_scene_shown()
	
	# Fix resolution/scaling issues after scene change
	_ensure_proper_scaling()
	
	if (target_index > 0):
		PlayerData.level = target_index
	Global.save_game()


func _ensure_proper_scaling() -> void:
	# Re-apply window/stretch settings to ensure they are consistent across scenes
	var window = get_window()
	if window:
		window.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
		window.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
		# Re-enforcing the scale factor and size
		window.content_scale_size = Vector2i(1600, 900)
		window.content_scale_factor = 2.5
		
		_recursive_update_layout(window)


func _recursive_update_layout(node: Node) -> void:
	if node is Control:
		node.queue_redraw()
		# Forcing a minimum size update can help some layouts snap to the correct size
		if node.anchors_preset == Control.PRESET_FULL_RECT:
			node.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	for child in node.get_children():
		_recursive_update_layout(child)


func on_new_game(player_names: Array, birthdates: Array) -> void:
	PlayerData.player_name_1 = player_names[0]
	PlayerData.birthdate_1 = birthdates[0]
	PlayerData.player_name_2 = player_names[1]
	PlayerData.birthdate_2 = birthdates[1]
	PlayerData.inv_slot = 0
	PlayerData.level = 11
	Global.isTutorial = true
	Global.lobby_doors_open = [true, false, true]
