extends Node2D
@onready var area = $Area2D

func _ready():
	area.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Player":
		print("Player detected")
		_drop_and_disable_passblocks()

func _drop_and_disable_passblocks():
	var passblocks = get_tree().get_nodes_in_group("PickedPassBlocks")
	Global.dropped_passblocks.append_array(passblocks.duplicate()) # Append PickedPassBlocks 
	for block in passblocks:
		block.drop_block() 
		block.set_interaction_area(false)
