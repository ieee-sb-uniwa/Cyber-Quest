extends StaticBody2D 

@onready var anim_sprite = $AnimatedSprite2D
@onready var area = $Area2D
@onready var load_area = $LoadArea
@onready var door_collider = $CollisionShape2D
var isOpen = false

# Add these properties to configure each door instance
@export var door_index: int = 0  # Which door this is (0, 1, 2, etc.)
@export var target_scene: String = "res://Levels/Lvl1_2.tscn"  # Scene to load
@export var is_terminal_unlock_door: bool = true  # Whether this door depends on terminal unlock

func _ready():
	area.body_entered.connect(_on_body_entered.bind("main_area"))
	area.body_exited.connect(_on_body_exited)
	load_area.body_entered.connect(_on_body_entered.bind("load_area"))
	anim_sprite.animation_finished.connect(_on_animation_finished)

func _on_body_entered(body, area_name=""):
	# player interacted with door
	if area_name == "main_area":
		if body.is_in_group("Player") and not isOpen:
			if can_open_door():
				open_door()
	# player went inside 	
	elif area_name == "load_area":
		# print("Loading next level...")
		# If this is a terminal unlock door, we are leaving tutorial
		if is_terminal_unlock_door:		
			Global.isTutorial = false

		# Change to the target scene
		Global.reset_variables()
		get_tree().call_deferred("change_scene_to_file", target_scene)
		

func _on_body_exited(body):
	if body.is_in_group("Player") and isOpen:
		close_door()

func can_open_door() -> bool:
	if is_terminal_unlock_door:
		# Original logic for non-lobby doors
		return Global.terminal_unlocked
	else:
		# Check if this lobby door is unlocked
		if door_index < Global.lobby_doors_open.size():
			return Global.lobby_doors_open[door_index]
		return false

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