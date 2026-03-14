extends StaticBody2D

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D

var players_on_bridge: Array = []

func _ready():
	sprite.hide()
	set_collision(false)

func set_collision(flag: bool):
	collision.call_deferred("set", "disabled", flag)

func _on_button_pressed():
	sprite.show()
	set_collision(true)
	print(collision.disabled)

func _on_button_unpressed():
	sprite.hide()
	set_collision(false)
	print(collision.disabled)
	for player in players_on_bridge:
			player.fall_down = true
			player.P_collission.disabled = true
			Global.request_respawn(player)
	players_on_bridge.clear()

func _on_area_body_entered(body):
	if body.is_in_group("Player"):
		players_on_bridge.append(body)

func _on_body_exited(body):
	if body.is_in_group("Player"):
		players_on_bridge.erase(body)
