extends Node2D


func _on_CoverArea_body_entered(body):
	if body.name == "Player":
		body.z_index = 1  # under the cover
		$Cover.z_index = 2

func _on_CoverArea_body_exited(body):
	if body.name == "Player":
		body.z_index = 3  # in front of bed again
