extends Node2D

@export var target_scene: PackedScene
@export var target_index: int = 0
@export var disable_door_index: int = 0
@onready var area: Area2D = $Area2D

func _ready():
	area.body_entered.connect(_on_area_body_entered)

func _on_area_body_entered(body: Node) -> void:
	# only react to players
	if not body.has_method("player"):
		return

	if Global.canExitLevel:
		if target_scene:  
			Global.lobby_doors_open[disable_door_index] = false
			Global.change_scene(target_scene.resource_path, target_index)
		else:
			push_error("DoorToLobby: target_scene not set")
