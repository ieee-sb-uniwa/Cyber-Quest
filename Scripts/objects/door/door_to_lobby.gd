extends Node2D

@export var target_scene: PackedScene
@onready var area: Area2D = $Area2D

func _ready():
    area.body_entered.connect(_on_area_body_entered)

func _on_area_body_entered(body: Node) -> void:
    # only react to players
    if not body.has_method("player"):
        return

    if Global.canExitLevel:
        if target_scene:
            get_tree().call_deferred("change_scene_to_packed", target_scene)
            Global.canExitLevel = false  # reset flag after use
        else:
            push_error("DoorToLobby: target_scene not set")