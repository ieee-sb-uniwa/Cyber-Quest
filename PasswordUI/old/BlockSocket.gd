extends TextureRect

var original_texture:Texture2D
var original_slot:TextureRect
var drag_started:=false


func _get_drag_data(_at_position): #triggers on click and drag
	original_texture=texture
	original_slot=self
	drag_started=true
	
	#creates draggable texture
	var preview_texture=TextureRect.new()
	preview_texture.texture=original_texture
	preview_texture.expand_mode=1
	preview_texture.size=Vector2(30,30)
	
	var preview=Control.new()
	preview.add_child(preview_texture)
	set_drag_preview(preview) #enables drag
	texture=null #makes initial texture disappear upon dragging
	
	return {"texture":original_texture, "from_slot":original_slot}


func _can_drop_data(_pos,data): #triggers upon hover while dragging
	return data is Dictionary and data.has("texture") and data.has("from_slot") #check if item is droppable


func _drop_data(_pos,data): #triggers on drop
	if texture and data["from_slot"]!=self:
		data["from_slot"].texture=texture
		
	var root = get_tree().current_scene
	if root.has_method("update_confirm_button"):
		root.update_confirm_button()
	
	texture=data["texture"] #assign dragged texture
	drag_started=false
	original_texture=null

	if root.has_method("reset_rules"):
		root.reset_rules()
	if root.has_method("update_confirm_button"):
		root.update_confirm_button()


func _notification(what):
	if what==NOTIFICATION_DRAG_END and drag_started:
		if not get_viewport().gui_is_drag_successful():
			texture=original_texture
		original_texture=null
		drag_started=false
