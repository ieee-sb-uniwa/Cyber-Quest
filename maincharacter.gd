extends CharacterBody2D

const speed = 300.0
@onready var animated_sprite_2d = $AnimatedSprite2D

func movement_control():
	velocity.x = 0.0
	velocity.y = 0.0
	var right = Input.is_action_pressed("right")
	var left = Input.is_action_pressed("left")
	var up = Input.is_action_pressed("up")
	var down = Input.is_action_pressed("down")
	if right:
		velocity.x += speed
		animated_sprite_2d.flip_h = false
	if left:
		velocity.x -= speed
		animated_sprite_2d.flip_h = true
	if up:
		velocity.y -= speed
	if down:
		velocity.y += speed

	if abs(velocity.x) == abs(velocity.y) and velocity.x != 0:
		velocity.x = velocity.x/1.4
		velocity.y = velocity.y/1.4

func animation_control():
	if velocity.x != 0 or velocity.y != 0:
		animated_sprite_2d.animation = "running"
	else:
		animated_sprite_2d.animation = "idle"

func _physics_process(delta):
	movement_control()
	animation_control()
	move_and_slide()
