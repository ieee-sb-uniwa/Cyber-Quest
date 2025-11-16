extends Node

var spawnIndex: int = 0

var player_1_asset: Node = null
var player_2_asset: Node = null
var camera_asset: Node = null
var spawn_points := [[],[]]	

func register_spawn_point(player_id: int, spawn_index: int, spawner_node: Node):
	# Ensure the player_id list exists
	while player_id >= spawn_points.size():
		spawn_points.append([])
	var player_spawn_list = spawn_points[player_id]
	while spawn_index >= player_spawn_list.size():
		player_spawn_list.append(null)
		
	player_spawn_list[spawn_index] = spawner_node
	spawn_points[player_id] = player_spawn_list  # Re-assign

func register_player(player_num: int, player_node: Node):
	if player_num==1:
		player_1_asset = player_node
	if player_num==2:
		player_2_asset = player_node
	
func respawn_players():
	# Defensive checks
	if camera_asset and is_instance_valid(camera_asset) and camera_asset.has_method("is_cam_enabled"):
		camera_asset.is_cam_enabled = false

	# Validate spawn points exist
	if spawn_points.size() < 2:
		push_error("SpawnManager: spawn_points missing or malformed")
		return
	var slist1 = spawn_points[0]
	var slist2 = spawn_points[1]
	if spawnIndex < 0 or spawnIndex >= slist1.size() or spawnIndex >= slist2.size():
		push_error("SpawnManager: spawnIndex out of range: %d" % spawnIndex)
		return
	var spawn1 = slist1[spawnIndex]
	var spawn2 = slist2[spawnIndex]
	if not spawn1 or not is_instance_valid(spawn1) or not spawn2 or not is_instance_valid(spawn2):
		push_error("SpawnManager: spawn points invalid at index %d" % spawnIndex)
		return
	# Do safe position updates
	if player_1_asset and is_instance_valid(player_1_asset):
		if "global_position" in player_1_asset:
			player_1_asset.global_position = spawn1.global_position
	else:
		push_warning("SpawnManager: player_1_asset missing when respawning")
	if player_2_asset and is_instance_valid(player_2_asset):
		if "global_position" in player_2_asset:
			player_2_asset.global_position = spawn2.global_position
	else:
		push_warning("SpawnManager: player_2_asset missing when respawning")
