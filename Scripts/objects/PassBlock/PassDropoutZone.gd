extends Node2D
@onready var area: Area2D = $InteractionArea
var currently_registered: bool = false

func _ready():
	area.set_object_type("passdropoutzone")
	area.action_name = "αφήσεις τα μπλοκ"
	area.interaction_status = Global.INTERACTION_STATUS.AVAILABLE
	
	# Disconnect automatic registration signals - we handle registration manually
	if area.body_entered.is_connected(area._on_body_entered):
		area.body_entered.disconnect(area._on_body_entered)
	if area.body_exited.is_connected(area._on_body_exited):
		area.body_exited.disconnect(area._on_body_exited)

func _process(_delta):
	var bodies = area.get_overlapping_bodies()
	
	# Check if any player in the area has items
	var player_with_items = null
	for body in bodies:
		if body.is_in_group("Player") and body.get_all_items().size() > 0:
			# print(body.get_all_items().size())
			player_with_items = body
			break
	
	# Register/unregister based on whether player has items
	if player_with_items and !currently_registered:
		InteractionManager.register_area(area, player_with_items)
		# print("Registered dropout zone")
		currently_registered = true
	elif !player_with_items and currently_registered:
		InteractionManager.unregister_area(area)
		# print("Unregistered dropout zone")
		currently_registered = false
	
	# Only handle interaction if player has items
	if !player_with_items:
		return
		
	# Check if this is the closest interaction area
	var closest_area = InteractionManager.get_closest_area()
	if closest_area != area:
		return
		
	# Handle interaction
	if (Global.player_interacts("Interact_p1", "MainPlayer", player_with_items) or Global.player_interacts("Interact_p2", "SecondPlayer", player_with_items)):
		_drop_and_disable_passblocks(player_with_items)

func _drop_and_disable_passblocks(body : Node2D):
	if !body.has_method("clear_all_items"):
		# print("Player doesn't have ItemHolder script")
		return
	
	# Get all items before clearing
	var items_to_drop = body.get_all_items().duplicate()
	# print("Dropping ", items_to_drop.size(), " items")
	
	# Drop items at the dropout zone position (isDelivered=true)
	body.clear_all_items(Vector2(global_position.x, global_position.y-25))
	
	# print("After clear_all_items, player has ", body.get_all_items().size(), " items")
	
	# Process each dropped block
	for block in items_to_drop:
		block.block_sprite.call_deferred("hide") # Hide the block sprite
		block.set_interaction_area(false) # Disable interaction area
		Global.add_passblock(block)
		# print("PassBlock added")
	
	# Immediately unregister after dropping items
	# print("Attempting to unregister, currently_registered: ", currently_registered)
	if currently_registered:
		InteractionManager.unregister_area(area)
		# print("Unregistered dropout zone after drop")
		currently_registered = false
