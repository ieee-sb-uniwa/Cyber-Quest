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
	camera_asset.is_cam_enabled = false
	var spawn1 = spawn_points[0][spawnIndex]
	var spawn2 = spawn_points[1][spawnIndex]
	print("respawning to "+str(spawn1.global_position))
	print("respawning to "+str(spawn2.global_position))
	player_1_asset.global_position = spawn1.global_position
	player_2_asset.global_position = spawn2.global_position


func unregister_player(player_node: Node) -> void:
	if player_1_asset == player_node:
		player_1_asset = null
	if player_2_asset == player_node:
		player_2_asset = null


func reset() -> void:
	player_1_asset = null
	player_2_asset = null
	camera_asset = null
	spawn_points = [[],[]]
	spawnIndex = 0
