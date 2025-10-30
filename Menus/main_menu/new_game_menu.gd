extends Control


var username1 = ""
var username2 = ""
var DoB1 = ""
var DoB2 = ""


# Called when the node enters the scene tree for the first time.
func _ready():
	$CenterContainer/CenteringCon/VBoxContainer/PlayerCount.text = "1"
	$CenterContainer/CenteringCon/Primary/Confirm.text = "Next"
	$CenterContainer/CenteringCon/Primary/NameIN.grab_focus()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_confirm_pressed() -> void:
	if $CenterContainer/CenteringCon/VBoxContainer/PlayerCount.text == "1" :
		username1 = $CenterContainer/CenteringCon/Primary/NameIN.text
		DoB1 = $CenterContainer/CenteringCon/Primary/DateIN.text
		if DoB1.length() != 10 || username1.length() == 0:
			#Pop-up saying its wrong
			pass
		$CenterContainer/CenteringCon/VBoxContainer/PlayerCount.text = "2"
		$CenterContainer/CenteringCon/Primary/Confirm.text = "Start!"
	else: 
		username2 = $CenterContainer/CenteringCon/Primary/NameIN.text
		DoB2 = $CenterContainer/CenteringCon/Primary/DateIN.text
		if DoB2.length() != 10 || username2.length() == 0:
			#Pop-up saying its wrong
			pass
		#Save my data to the proper folder to be used later
		get_tree().change_scene_to_file("res://Levels/Lvl1_r1.tscn")
