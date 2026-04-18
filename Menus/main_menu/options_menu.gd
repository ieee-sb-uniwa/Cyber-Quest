extends Control;

func _ready():
	$Buttons/BacktoMenu.grab_focus();
	$Sliders/MusicSlider.value = db_to_linear(AudioPlayer.music_vol)

func _on_backto_menu_pressed():
	get_tree().change_scene_to_file("res://Menus/main_menu/Menu.tscn");

func _on_resume_playing_pressed() -> void:
	$"../InventoryGUI".show()
	$"../../".show()
	queue_free()	# Destroys the instanced options node

func _on_music_slider_value_changed(value:float) -> void:
	AudioPlayer.play_music_menu(linear_to_db(value))
