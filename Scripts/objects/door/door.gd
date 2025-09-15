extends StaticBody2D 

@onready var anim_sprite = $AnimatedSprite2D
@onready var area = $Area2D
@onready var load_area = $LoadArea
@onready var door_collider = $CollisionShape2D
var isOpen = false

func _ready():
	area.body_entered.connect(_on_body_entered.bind("main_area"))
	area.body_exited.connect(_on_body_exited)
	load_area.body_entered.connect(_on_body_entered.bind("load_area"))
	anim_sprite.animation_finished.connect(_on_animation_finished)

func _on_body_entered(body, area_name=):
	if area_name == "main_area":
		if Global.terminal_unlocked and body.is_in_group("Player") and not isOpen:
			open_door()
	elif area_name == "load_area":
		print("Loading next level...")
		# await get_tree().create_timer(2.0).timeout # Waits for 2 seconds
		# HERE DO ALL THE STUFF TO RESET THE LEVEL VARIABLES IF NEEDED
		Global.reset_variables() 
		get_tree().call_deferred("change_scene_to_file", "res://Levels/Lvl1_r2.tscn")

func _on_body_exited(body):
	if body.is_in_group("Player") and isOpen:
		close_door()

func open_door():
	isOpen = true
	anim_sprite.play("open")

func close_door():
	isOpen = false
	anim_sprite.play("close")
	door_collider.set_deferred("disabled", false)

func _on_animation_finished():
	if isOpen:
		door_collider.set_deferred("disabled", true)
