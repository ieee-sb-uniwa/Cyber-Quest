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
var player_index : int =0

func add_item(item:Node2D)->void:
	if items_available_positions.size() <= assigned_items.size():
		print("Your inventory is full.")
		return
	item.get_parent().remove_child(item)
	self.add_child(item)
	assigned_items.append(item)
	var currDir = lastDir
	lastDir = Global.MOVE_ORIENTATION.EMPTY
	change_items_orientation(currDir)
	print("Item "+item.name+" added!")

func remove_item_from_character(item:Node2D, pos : Vector2) -> void:
	if assigned_items.find(item) == -1:
		print("This item does not excist in the inventory.")
		return
	self.remove_child(item)
	var pass_blocks = get_tree().current_scene.get_node("PassBlocks")
	if pass_blocks == null:
		printerr("No passBlocks node found")
		return
	pass_blocks.call_deferred("add_child", item)  
	item.global_position = pos
	print("Item "+item.name+ " has been removed from the inventory.")

func get_all_items() -> Array[Node2D]:
	return assigned_items

func clear_all_items(pos : Vector2) -> void:
	for i in assigned_items.size():
		remove_item_from_character(assigned_items[i], Vector2(pos.x, pos.y + items_available_positions[i].position.y))
	assigned_items.clear()
	
func set_player_index(index : int) -> void:
	player_index = index
	
func change_items_orientation(move_orientation : Global.MOVE_ORIENTATION) -> void:
	#TODO handle orientaion of items from the rotation of character
	if lastDir == move_orientation:
		return
	lastDir = move_orientation
	for i in assigned_items.size():
		assigned_items[i].position = item_offsets.get(move_orientation) + items_available_positions[i].position
		assigned_items[i].z_index = player_index + i - item_index.get(move_orientation)*assigned_items.size()
	print("change orientation to: " + str(Global.MOVE_ORIENTATION.find_key(move_orientation)))
