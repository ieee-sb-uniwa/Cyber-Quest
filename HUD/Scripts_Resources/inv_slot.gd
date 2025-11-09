extends Panel

@onready var itemSprite : Sprite2D = $CenterContainer/Panel/item

func update(item: InventoryItem):
	if !item:
		itemSprite.visible = false
	else:
		itemSprite.visible = true
		itemSprite.texture = item.texture
		# Scale down the sprite to fit the 44x44 slot (adjust scale as needed)
		if itemSprite.texture:
			var texture_size = itemSprite.texture.get_size()
			var slot_size = 32.0  # The slot is 32x32 pixels
			var scale_factor = slot_size / max(texture_size.x, texture_size.y)
			itemSprite.scale = Vector2(scale_factor, scale_factor)
