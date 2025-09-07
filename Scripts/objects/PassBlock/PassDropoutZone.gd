extends Node2D
@onready var area = $Area2D

func _ready():
	area.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.has_method("player"):
		# print("Player detected")
		_drop_and_disable_passblocks(body)

func _drop_and_disable_passblocks(body : Node2D):
	if !body.has_method("add_item_to_holder"):
		print("Player doesn't have ItemHolder script")
		return
	Global.dropped_passblocks.append_array(body.get_all_items())
	# print(body)
	for block in Global.dropped_passblocks:
		block.drop_block(body) 
		block.set_interaction_area(false)
	# print("Dropped passblocks: ", Global.dropped_passblocks)
	body.clear_all_items()
