extends Area2D
class_name InteractionArea

@export var action_key: String = "Interact"
@export var action_name: String = "Interact"
var area_label : Label

var interact: Callable = func():
	pass

func _on_body_entered(_body):
	InteractionManager.register_area(self)
	Global.interacable = true
	area_label = InteractionManager.get_label()

func _on_body_exited(_body):
	InteractionManager.unregister_area(self)
	Global.interacable = false
	area_label = InteractionManager.get_label()
	area_label.hide()

# Getter method to access the label
func get_label() -> Label:
	return area_label
	
# Setter method to update the label
func set_label(new_text: String) -> void:
	if area_label:
		area_label.text = new_text
