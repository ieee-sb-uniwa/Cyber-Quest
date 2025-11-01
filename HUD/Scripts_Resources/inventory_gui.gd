extends Control
class_name InventoryGUI

# Enum to map level to keyboard image path
enum KeyboardImages {
	LEVEL_1 = 1,
	LEVEL_2 = 2,
	LEVEL_3 = 3,
	LEVEL_4 = 4
}

# Dictionary mapping level to keyboard image path
const LEVEL_TO_KEYBOARD : Dictionary = {
	1: "res://HUD/sprites/keyboards.png",  # Replace with specific keyboard01 path when available
	2: "res://HUD/sprites/keyboards.png",  # Replace with specific keyboard02 path when available
	3: "res://HUD/sprites/keyboards.png",  # Replace with specific keyboard03 path when available
	4: "res://HUD/sprites/keyboards.png"   # Replace with specific keyboard04 path when available
}

@onready var inventory : Inventory = preload("res://HUD/Scripts_Resources/Player_Inventory.tres")
@onready var slots : Array = $GridContainer.get_children()

func _ready():
	Global.inventory_gui = self
	update()

func update():
	for i in range(min(inventory.items.size(), slots.size())):
		slots[i].update(inventory.items[i])

# Function to unlock inventory item based on player level
func unlock_inventory_for_level(level: int):
	if level > 0 and level <= LEVEL_TO_KEYBOARD.size():
		var item = InventoryItem.new()
		item.name = "Keyboard Level " + str(level)
		item.texture = load(LEVEL_TO_KEYBOARD[level])
		
		# Add item to the appropriate slot (level - 1 for zero-based index)
		if level - 1 < inventory.items.size():
			inventory.items[level - 1] = item
			update()

# Function to sync inventory with PlayerData level
func sync_with_player_data():
	var player_data = get_node("/root/PlayerData")  # Adjust path as needed
	if player_data:
		for i in range(1, player_data.level + 1):
			if i <= LEVEL_TO_KEYBOARD.size():
				unlock_inventory_for_level(i)
