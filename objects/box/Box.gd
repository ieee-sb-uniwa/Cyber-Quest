extends StaticBody2D

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var player_visible: CollisionShape2D = $"../../Player/CollisionShape2D"
func _ready():
	interaction_area.interact = Callable(self, "_hide_in_box")


func _hide_in_box():
	if player_visible.visible == true:
		player_visible.visible = false
		print("hidden")
	else:
		print("not hidden")
		player_visible.visible = true
