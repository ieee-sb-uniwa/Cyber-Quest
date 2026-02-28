extends StaticBody2D

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D

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
