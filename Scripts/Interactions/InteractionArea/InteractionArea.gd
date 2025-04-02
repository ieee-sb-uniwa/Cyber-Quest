extends Area2D
class_name InteractionArea

@export var action_key: String = "Interact"
@export var action_name: String = "Interact"

var interact: Callable = func():
	pass
	

func _on_body_entered(body):
	InteractionManager.register_area(self)
	print("entered")
	Global.interacable = true

func _on_body_exited(body):
	InteractionManager.unregister_area(self)
	print("exited")
	Global.interacable = false
