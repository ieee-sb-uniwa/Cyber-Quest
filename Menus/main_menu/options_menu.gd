extends Control;


# Called when the node enters the scene tree for the first time.
func _ready():
	$VBoxContainer2/BacktoMenu.grab_focus();
	$VBoxContainer/MusicSlider.value = db_to_linear(AudioPlayer.music_vol)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_backto_menu_pressed():
	Controller._open_menu_scene("Main_Menu")

# func _on_resume_playing_pressed() -> void:
# 	THIS HAS BEEN DISABLED AS IT IS OLD LOGIC
# 	$"../InventoryGUI".show()
# 	$"../../".show()
# 	#queue_free() Destroys the instanced options node


func _on_music_slider_value_changed(value:float) -> void:
	AudioPlayer.play_music_menu(linear_to_db(value))
