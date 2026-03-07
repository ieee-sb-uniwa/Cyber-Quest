extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	$VBoxContainer/New.grab_focus();
	AudioPlayer.play_music_menu(AudioPlayer.music_vol)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _exit_tree():
	if has_node("TitleMusic"):
		$TitleMusic.stop()
		$TitleMusic.queue_free()

func _on_new_pressed():
	Controller._open_menu_scene("Newgame_Menu")

func _on_load_pressed():
	Controller._open_menu_scene("Load_Menu")

func _on_options_pressed():
	Controller._open_menu_scene("Options_Menu")

func _on_quit_pressed():
	get_tree().quit();
