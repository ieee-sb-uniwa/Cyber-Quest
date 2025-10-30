extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	$VBoxContainer2/BacktoMenu.grab_focus();


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_backto_menu_pressed():
	get_tree().change_scene_to_file("res://Menus/main_menu/Menu.tscn");
