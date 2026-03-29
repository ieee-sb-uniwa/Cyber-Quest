extends Area2D

const Balloon = preload("res://Dialogues/Level_Dialogues/Balloons/example_balloons/balloon.tscn")

@export var dialogue_resource: DialogueResource
@export var dialogue_start: String = "start"
var has_entered = false

func _on_body_entered(body: Node2D) -> void:
	if has_entered == false:
		has_entered = true
		var balloon: Node = Balloon.instantiate()
		get_tree().current_scene.add_child(balloon)
		balloon.start(dialogue_resource, dialogue_start)
	else:
		pass
