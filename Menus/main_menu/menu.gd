extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	$VBoxContainer/New.grab_focus();

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_new_pressed():
	get_tree().change_scene_to_file("res://Levels/Lvl1_r1.tscn");

func _on_load_pressed():
	get_tree().change_scene_to_file("res://Menu/Load-Menu.tscn");

func _on_options_pressed():
	get_tree().change_scene_to_file("res://Menu/Options-Menu.tscn");


func _on_quit_pressed():
	get_tree().quit();
