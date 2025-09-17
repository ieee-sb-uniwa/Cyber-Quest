extends Area2D
class_name InteractionArea

@export var action_key: String 
@export var action_name: String
var area_label : Label
var object_type : String
var interaction_status:Global.INTERACTION_STATUS = Global.INTERACTION_STATUS.EMPTY

var interact: Callable = func():
	pass

func _ready():
	area_label = InteractionManager.get_label()
	area_label.hide()
	self.body_entered.connect(_on_body_entered)
	self.body_exited.connect(_on_body_exited)

func _on_body_entered(_body):
	if interaction_status!=Global.INTERACTION_STATUS.EMPTY and  interaction_status!=Global.INTERACTION_STATUS.AVAILABLE:
		return

	if (can_pickup(_body) or (object_type != null and object_type != "")):
		InteractionManager.register_area(self, _body)

func _on_body_exited(_body):
	if interaction_status!=Global.INTERACTION_STATUS.EMPTY and interaction_status!=Global.INTERACTION_STATUS.AVAILABLE:
		return
	InteractionManager.unregister_area(self)
	area_label = InteractionManager.get_label()
	area_label.hide()

# Getter method to access the label
func get_label() -> Label:
	return area_label
	
func set_object_type(text : String):
	object_type = text
	
# Setter method to update the label
func set_label(new_text: String) -> void:
	if area_label:
		area_label.text = new_text

func can_pickup(body: Node2D) -> bool:
	if body.is_in_group("MainPlayer") and Global.player_blocks[0] < Global.max_player_items:
		return true
	elif body.is_in_group("SecondPlayer") and Global.player_blocks[1] < Global.max_player_items:
		return true
	else:
		return false