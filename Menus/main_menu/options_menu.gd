extends Control;

func _ready():
	$Settings/MusicSlider.value = db_to_linear(AudioPlayer.music_vol)
	$Settings/NumpadCheck.button_pressed = Settings.p2_control_scheme == Settings.SCHEME_NUMPAD

func _on_backto_menu_pressed():
	get_tree().change_scene_to_file("res://Menus/main_menu/Menu.tscn");

func _on_resume_playing_pressed() -> void:
	$"../InventoryGUI".show()
	$"../../".show()
	queue_free()	# Destroys the instanced options node

func _on_music_slider_value_changed(value:float) -> void:
	AudioPlayer.play_music_menu(linear_to_db(value))

func _on_numpad_check_toggled(toggled_on: bool) -> void:
	# pick scheme based on the toggle state and apply it
	var scheme
	if toggled_on:
		scheme = Settings.SCHEME_NUMPAD
	else:
		scheme = Settings.SCHEME_NO_NUMPAD
	Settings.set_p2_control_scheme(scheme)
