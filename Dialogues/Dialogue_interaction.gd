extends Area2D
var entered = false

func _on_body_entered(_body):
	if entered == false:
		entered = true
		DialogueManager.show_example_dialogue_balloon(load("res://Dialogues/dialogue.dialogue"))
		return 
