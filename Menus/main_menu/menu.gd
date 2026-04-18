extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	$Buttons/New.grab_focus();
	AudioPlayer.play_music_menu(AudioPlayer.music_vol)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _exit_tree():
	if has_node("TitleMusic"):
		$TitleMusic.stop()
		$TitleMusic.queue_free()

func _on_new_pressed():
	_cleanup_before_scene_change()
	get_tree().call_deferred("change_scene_to_file", "res://Menus/main_menu/NewGame_Menu.tscn");

func _on_load_pressed():
	_cleanup_before_scene_change()
	get_tree().call_deferred("change_scene_to_file", "res://Menus/main_menu/Load-Menu.tscn");

func _on_options_pressed():
	_cleanup_before_scene_change()
	get_tree().call_deferred("change_scene_to_file", "res://Menus/main_menu/Options-Menu.tscn");

func _on_quit_pressed():
	_cleanup_before_scene_change()
	get_tree().quit();

func _cleanup_before_scene_change():
	if has_node("TitleMusic"):
		$TitleMusic.stop()
		$TitleMusic.queue_free()
