extends Resource
# δημιουργει ενα resource inventory που περιεχει ενα πινακα απο inventory items
class_name Inventory 
# ο πινακας δεχεται μονο στοιχεια απο το resource inventory_item 
@export var items: Array[InventoryItem]
