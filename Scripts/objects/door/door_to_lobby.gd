extends Node2D

@export var target_scene: PackedScene
@export var target_index: int = 0
@onready var area: Area2D = $Area2D

func _ready():
    area.body_entered.connect(_on_area_body_entered)

func _on_area_body_entered(body: Node) -> void:
    # only react to players
    if not body.has_method("player"):
        return

    if Global.canExitLevel:
        if target_scene:
            Global.reset_variables()    
            Global.lobby_doors_open[target_index] = false
            get_tree().call_deferred("change_scene_to_packed", target_scene)
        else:
            push_error("DoorToLobby: target_scene not set")