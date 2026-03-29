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
	1: "res://HUD/sprites/keyboard_key01.tres",  # AtlasTexture for first key
	2: "res://HUD/sprites/keyboard_key02.tres",  # AtlasTexture for second key
	3: "res://HUD/sprites/keyboard_key03.tres",  # AtlasTexture for third key
	4: "res://HUD/sprites/keyboard_key04.tres"   # AtlasTexture for fourth key
}

@onready var inventory : Inventory = preload("res://HUD/Scripts_Resources/Player_Inventory.tres")
@onready var slots : Array = $GridContainer.get_children()

func _ready():
	Global.inventory_gui = self
	sync_with_player_data()
	update()

func update():
	for i in range(min(inventory.items.size(), slots.size())):
		slots[i].update(inventory.items[i])

# Function to unlock inventory item based on player level
func unlock_inventory_for_level(level: int):
	if level > 0 and level <= LEVEL_TO_KEYBOARD.size():
		var slot_index = level - 1
		
		# Check if item already exists in this slot to prevent duplicates
		if slot_index < inventory.items.size():
			if inventory.items[slot_index] == null:
				var item = InventoryItem.new()
				item.name = "Keyboard Level " + str(level)
				item.texture = load(LEVEL_TO_KEYBOARD[level])
				inventory.items[slot_index] = item
				update()

# Function to sync inventory with PlayerData level
func sync_with_player_data():
	var player_data = get_node("/root/PlayerData")  # Adjust path as needed
	if player_data:
		# Clear inventory
		clear_inventory()
		for i in range(1, player_data.inv_slot + 1):
			if i <= LEVEL_TO_KEYBOARD.size():
				unlock_inventory_for_level(i)

# Function to clear all inventory items
func clear_inventory():
	for i in range(inventory.items.size()):
		inventory.items[i] = null
	update()
