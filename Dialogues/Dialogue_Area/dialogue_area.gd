extends Area2D

@export var dialogue_resource: DialogueResource
@export var dialogue_start: String = "start"
var has_entered = false

func _on_body_entered(body: Node2D) -> void:
	if has_entered == false:
		has_entered = true
		DialogueManager.show_example_dialogue_balloon(dialogue_resource,dialogue_start)
	else:
		pass
