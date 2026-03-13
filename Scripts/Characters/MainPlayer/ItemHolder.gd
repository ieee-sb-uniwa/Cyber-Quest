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

func remove_item_from_character(pl:Node2D, item:Node2D, pos : Vector2, isDelivered:bool) -> void:
	if assigned_items.find(item) == -1:
		print("This item does not excist in the inventory.")
		return
	if !isDelivered && item.has_method("drop_block"):
		item.drop_block(pl)
	self.remove_child(item)
	var pass_blocks = Controller.current_scene.get_node("Environment/PassBlocks") 
	if pass_blocks == null:
		printerr("No passBlocks node found. Check the scene structure. There should be a direct child PassBlocks node.")
		return
	item.set_collision_layer_value(6,true)
	item.set_collision_layer_value(30,false)
	pass_blocks.call_deferred("add_child", item)  
	item.global_position = pos

func get_all_items() -> Array[Node2D]:
	return assigned_items

func clear_all_items(pl:Node2D, isDelivered:bool) -> void:
	var pos = pl.global_position
	for i in assigned_items.size():
		remove_item_from_character(pl, assigned_items[i], Vector2(pos.x, pos.y + items_available_positions[i].position.y), isDelivered)
	assigned_items.clear()
	
func set_player_index(index : int) -> void:
	player_index = index

func change_items_orientation(move_orientation : Global.MOVE_ORIENTATION, is_flipped: bool = false) -> void:
	if lastDir == move_orientation:
		return
	lastDir = move_orientation
	
	for i in assigned_items.size():
		var offset = item_offsets.get(move_orientation)
		
		# Only flip the offset for horizontal directions when the player is flipped
		if is_flipped and move_orientation == Global.MOVE_ORIENTATION.LEFT:
			# When facing left and flipped, use the right offset but flipped
			offset = item_offsets.get(Global.MOVE_ORIENTATION.RIGHT)
			offset.x = -offset.x  # Flip the x offset
		elif is_flipped and move_orientation == Global.MOVE_ORIENTATION.RIGHT:
			# When facing right and flipped, use the left offset but flipped
			offset = item_offsets.get(Global.MOVE_ORIENTATION.LEFT)
			offset.x = -offset.x  # Flip the x offset
		
		assigned_items[i].position = offset + items_available_positions[i].position
		assigned_items[i].z_index = player_index + i - item_index.get(move_orientation)*assigned_items.size()
