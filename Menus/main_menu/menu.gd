extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	$VBoxContainer/New.grab_focus();

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_new_pressed():
	get_tree().call_deferred("change_scene_to_file", "res://Menus/main_menu/NewGame_Menu.tscn");

func _on_load_pressed():
	get_tree().call_deferred("change_scene_to_file", "res://Menus/main_menu/Load-Menu.tscn");

func _on_options_pressed():
	get_tree().call_deferred("change_scene_to_file", "res://Menus/main_menu/Options-Menu.tscn");

func _on_quit_pressed():
	get_tree().quit();
