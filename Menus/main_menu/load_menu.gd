extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	var canLoad = Global.saveData.load_game()
	if canLoad:
		$CenterVbox/VBoxContainer/N1.text = "Player 1: " + PlayerData.player_name_1 + "\n Player 2:" + PlayerData.player_name_2
	$VBoxContainer2/BacktoMenu.grab_focus();
	print(get_tree().get_current_scene())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_backto_menu_pressed():
	get_tree().call_deferred("change_scene_to_file", "res://Menus/main_menu/Menu.tscn")


func _on_n_1_pressed() -> void:
	var lvl_val = int(PlayerData.level)
	var level = int(floor(lvl_val / 10.0))
	var scene = int(lvl_val % 10)
	var path = "res://Levels/Lvl%d_%d.tscn" % [level, scene]
	print(path)
	# Diagnostics: print tree and root children to help trace crash when changing scenes
	print("[LoadMenu] Tree paused:", get_tree().paused)
	var root := get_tree().get_root()
	print("[LoadMenu] Root child count:", root.get_child_count())
	for i in range(root.get_child_count()):
		var c = root.get_child(i)
		# Avoid accessing properties that may not exist on scripted nodes
		var node_class = ""
		if c:
			node_class = c.get_class()
		print("[LoadMenu] Root child:", i, "+", c.name, "class:", node_class)
	# Try loading the scene resource first (packed) and change to it deferred.
	var packed = ResourceLoader.load(path)
	if packed == null:
		push_error("Load failed: could not load resource at %s" % path)
		return
	if not packed is PackedScene:
		push_error("Load failed: resource is not a PackedScene: %s" % path)
		return
	# Defer the actual scene change to avoid switching scenes during the button callback.
	# Use a deferred helper that unpauses, yields a frame or two, then switches scenes.
	# Call deferred on this node so `_deferred_change_to_packed` is found
	call_deferred("_deferred_change_to_packed", packed)


func _deferred_change_to_packed(packed_scene) -> void:
	# Defensive: ensure we have a PackedScene
	if packed_scene == null:
		push_error("Deferred load failed: null packed scene")
		return
	if not packed_scene is PackedScene:
		push_error("Deferred load failed: resource is not a PackedScene")
		return
	# Unpause if necessary so nodes can process their exit logic
	if get_tree().paused:
		get_tree().paused = false
	# Wait a frame (or two) to let nodes finish any immediate signals/teardown
	await get_tree().process_frame
	await get_tree().process_frame
	# Try engine scene change first (returns an error code), but fall back to manual instancing
	var err = get_tree().change_scene_to_packed(packed_scene)
	print("change_scene_to_packed returned:", err)
	if err != OK:
		print("Engine change_scene_to_packed returned error - falling back to manual instantiation")
		# Manual instantiation: add new scene as child of root and set as current scene, then free old
		var old_scene = get_tree().get_current_scene()
		var new_scene = packed_scene.instantiate()
		if new_scene == null:
			push_error("Manual instantiation failed: instantiate returned null")
			return
		get_tree().get_root().add_child(new_scene)
		get_tree().set_current_scene(new_scene)
		if old_scene:
			old_scene.queue_free()
		print("Manual scene switch completed")


func _on_n_2_pressed() -> void:
	pass # Replace with function body.


func _on_n_3_pressed() -> void:
	pass # Replace with function body.
