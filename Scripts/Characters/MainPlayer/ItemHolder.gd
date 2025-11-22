class_name ItemHolder
extends Node2D

@export var items_available_positions: Array[Node2D]
var assigned_items: Array[Node2D]
var lastDir : Global.MOVE_ORIENTATION = Global.MOVE_ORIENTATION.UP
var item_offsets := {
	Global.MOVE_ORIENTATION.UP: Vector2(0, 10),
	Global.MOVE_ORIENTATION.DOWN: Vector2(0, 6),
	Global.MOVE_ORIENTATION.LEFT: Vector2(18, 6),
	Global.MOVE_ORIENTATION.RIGHT: Vector2(-18, 6)
}
var item_index := {
	Global.MOVE_ORIENTATION.UP: int(0),
	Global.MOVE_ORIENTATION.DOWN: int(1),
	Global.MOVE_ORIENTATION.LEFT: int(1),
	Global.MOVE_ORIENTATION.RIGHT: int(1)
}
var player_index : int = 0

func add_item(item:Node2D)->void:
	if items_available_positions.size() <= assigned_items.size():
		print("Your inventory is full.")
		return
	item.get_parent().remove_child(item)
	self.add_child(item)
	item.set_collision_layer_value(6,false)
	item.set_collision_layer_value(30,true)
	assigned_items.append(item)
	var currDir = lastDir
	lastDir = Global.MOVE_ORIENTATION.EMPTY
	change_items_orientation(currDir)
	# print("Item "+item.name+" added!")

func remove_item_from_character(pl:Node2D, item:Node2D, pos : Vector2, isDelivered:bool, index:int) -> void:
	if assigned_items.find(item) == -1:
		print("This item does not exist in the inventory.")
		return
	if !isDelivered && item.has_method("drop_block"):
		item.drop_block(pl)
	
	# Remove from assigned_items array
	assigned_items.erase(item)
	
	self.remove_child(item)
	#! Assuming PassBlocks is a direct child of the current scene
	var pass_blocks = get_tree().current_scene.get_node("Environment/PassBlocks") 
	if pass_blocks == null:
		printerr("No passBlocks node found. Check the scene structure. There should be a direct child PassBlocks node.")
		return
	item.set_collision_layer_value(6,true)
	item.set_collision_layer_value(30,false)
	pass_blocks.call_deferred("add_child", item)  
	item.global_position = pos
	item.z_index = 15+index  # Ensure items are visible above other objects
	# print("Item "+item.name+ " has been removed from the inventory.")

func get_all_items() -> Array[Node2D]:
	return assigned_items

func clear_all_items(pl:Node2D, isDelivered:bool, positionToDrop: Vector2 = Vector2.ZERO) -> void:
	var pos = pl.global_position
	# Create a copy of the array to iterate over
	var items_to_remove = assigned_items.duplicate()
	
	for i in items_to_remove.size():
		# Use positionToDrop if provided (not Vector2.ZERO), otherwise use player position with offset
		var drop_pos = positionToDrop if positionToDrop != Vector2.ZERO else Vector2(pos.x, pos.y + items_available_positions[i].position.y)
		if positionToDrop != Vector2.ZERO:
			print(Global.dropped_passblocks.size())
			drop_pos = Vector2(drop_pos.x, drop_pos.y - 10*Global.dropped_passblocks.size()) # Offset each dropped block vertically
		remove_item_from_character(pl, items_to_remove[i], drop_pos, isDelivered, i)
	assigned_items.clear()
	
func set_player_index(index : int) -> void:
	player_index = index
	
func change_items_orientation(move_orientation : Global.MOVE_ORIENTATION) -> void:
	if lastDir == move_orientation:
		return
	lastDir = move_orientation
	for i in assigned_items.size():
		assigned_items[i].position = item_offsets.get(move_orientation) + items_available_positions[i].position
		assigned_items[i].z_index = player_index + i - item_index.get(move_orientation)*assigned_items.size()
	# print("change orientation to: " + str(Global.MOVE_ORIENTATION.find_key(move_orientation)))
