extends Node

var main_menu_scene = preload("res://Menus/main_menu/Menu.tscn")
var current_scene = null

func _ready() -> void:
    _open_scene(main_menu_scene)

func _open_scene(scene: PackedScene) -> void:
    if current_scene:
        current_scene.queue_free()
    current_scene = scene.instantiate()
    add_child(current_scene)