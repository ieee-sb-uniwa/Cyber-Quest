extends StaticBody2D 

@onready var anim_sprite = $AnimatedSprite2D
@onready var area = $Area2D
@onready var door_collider = $CollisionShape2D
var is_open = false

func _ready():
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)
	anim_sprite.animation_finished.connect(_on_animation_finished)

func _on_body_entered(body):
	if body.name == "Player" and not is_open:
		open_door()

func _on_body_exited(body):
	if body.name == "Player" and is_open:
		close_door()

func open_door():
	is_open = true
	anim_sprite.play("open")

func close_door():
	is_open = false
	anim_sprite.play("close")
	door_collider.set_deferred("disabled", false)

func _on_animation_finished():
	if is_open:
		door_collider.set_deferred("disabled", true)
