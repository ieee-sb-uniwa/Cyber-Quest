extends StaticBody2D

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var player_visible: CollisionShape2D = $"../../Player/CollisionShape2D"


func _ready():
	interaction_area.interact = Callable(self, "_hide_in_box")


func _hide_in_box():
	if Global.Hide_status == 1 :
		Global.Hide_status = 0
		$Box_Sprite.set_frame(0)
		print("hidden")
		print(Global.Hide_status)
	else:
		if Global.Hide_status == 0:
			Global.Hide_status = 1
			$Box_Sprite.set_frame(1)
			print("not hidden")
			print(Global.Hide_status)
