extends StaticBody2D

@onready var fan_anim_sprite = $AnimatedSprite2D


func _on_ready() -> void:
	fan_anim_sprite.play("default")
