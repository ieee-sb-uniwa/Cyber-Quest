extends Control

signal key_pressed(key_value, key_type)

@export var custom_font: Font
@export var letter_key_scene: PackedScene
@export var symbol_key_scene: PackedScene
@export var letter_key_size: Vector2 = Vector2(60, 60)
@export var letter_key_spacing: Vector2 = Vector2(-2, -14)
@export var symbol_key_size: Vector2 = Vector2(45, 45)
@export var symbol_key_spacing: Vector2 = Vector2(0, 2)

@export var numpad_container: Control
@export var letter_container: Control  
@export var symbol_container: Control

var current_keys: Array = []
var is_uppercase: bool = false

func setup_level_layouts(level: int):
	clear_keyboard()
	
	match level:
		1:
			_create_keys_in_container("numpad", numpad_container, Vector2(0, 0))
			letter_container.visible = false
			symbol_container.visible = false
		2:
			_create_keys_in_container("numpad", numpad_container, Vector2(0, 0))
			_create_keys_in_container("qwerty_lower", letter_container, Vector2(0, 0))
			symbol_container.visible = false
		3:
			_create_keys_in_container("numpad", numpad_container, Vector2(0, 0))
			_create_keys_in_container("qwerty_lower", letter_container, Vector2(0, 0))
			_create_keys_in_container("symbols", symbol_container, Vector2(0, 0))

func _create_keys_in_container(layout_name: String, container: Control, position_offset: Vector2):
	# Container for keys and labels
	container.queue_redraw()
	await get_tree().process_frame
	
	var layout_data = KeyboardLayouts.get_layout(layout_name)
	
	if layout_data.has("rows"):
		_create_keys_from_rows(layout_data, container, position_offset)
	else:
		_create_keys_from_grid(layout_data, container, position_offset)

func _create_keys_from_rows(layout_data: Dictionary, container: Control, position_offset: Vector2):
	var key_size_to_use: Vector2
	var key_spacing_to_use: Vector2
	
	if layout_data.name == "symbols":
		key_size_to_use = symbol_key_size
		key_spacing_to_use = symbol_key_spacing
	else:
		key_size_to_use = letter_key_size  
		key_spacing_to_use = letter_key_spacing
	
	var row_height = key_size_to_use.y + key_spacing_to_use.y
	var current_y = position_offset.y
	
	for row_index in range(layout_data.rows.size()):
		var row_data = layout_data.rows[row_index]
		var row_keys = row_data.keys
		var key_count = row_data.key_count

		var total_row_width = (key_count * key_size_to_use.x) + ((key_count - 1) * key_spacing_to_use.x)
		var start_x = position_offset.x + ((container.size.x - total_row_width) / 2)

		var actual_key_index = 0
		
		for key_index in range(row_keys.size()):
			var key_info = row_keys[key_index]
			
			if key_info.display.is_empty():
				actual_key_index += 1
				continue
			
			var key_scene_to_use
			if key_info.type == "symbol":
				key_scene_to_use = symbol_key_scene
			else:
				key_scene_to_use = letter_key_scene
			
			var key = key_scene_to_use.instantiate()
			container.add_child(key)
			
			key.key_value = key_info.value
			key.key_display = key_info.display
			key.key_type = key_info.type
			
			if custom_font != null:
				key.custom_font = custom_font
			
			var x_pos = start_x + (actual_key_index * (key_size_to_use.x + key_spacing_to_use.x))
			
			_deferred_set_position(key, Vector2(x_pos, current_y))
			key.set_deferred("size", key_size_to_use)
			
			key.key_pressed.connect(_on_key_pressed)
			current_keys.append(key)
			
			actual_key_index += 1

		current_y += row_height

func _create_keys_from_grid(layout_data: Dictionary, container: Control, position_offset: Vector2):
	var key_size_to_use = letter_key_size
	var key_spacing_to_use = letter_key_spacing
	
	var rows = layout_data.rows
	var columns = layout_data.columns
	var button_index = 0
	
	for row in range(rows):
		for col in range(columns):
			if button_index >= layout_data.keys.size():
				return
				
			var key_info = layout_data.keys[button_index]
			
			if key_info.display.is_empty():
				button_index += 1
				continue
			
			var key_scene_to_use = letter_key_scene
			
			var key = key_scene_to_use.instantiate()
			container.add_child(key)
			
			key.key_value = key_info.value
			key.key_display = key_info.display  
			key.key_type = key_info.type
			
			var x_pos = position_offset.x + (col * (key_size_to_use.x + key_spacing_to_use.x))
			var y_pos = position_offset.y + (row * (key_size_to_use.y + key_spacing_to_use.y))
			
			_deferred_set_position(key, Vector2(x_pos, y_pos))
			key.size = key_size_to_use
			
			key.key_pressed.connect(_on_key_pressed)
			current_keys.append(key)
			button_index += 1

func _deferred_set_position(key_node: Control, pos: Vector2):
	call_deferred("_set_key_position", key_node, pos)

func _set_key_position(key_node: Control, pos: Vector2):
	key_node.position = pos

func _on_key_pressed(key_value: String, key_type: String):
	emit_signal("key_pressed", key_value, key_type)

func clear_keyboard():
	for key in current_keys:
		key.queue_free()
	current_keys.clear()
