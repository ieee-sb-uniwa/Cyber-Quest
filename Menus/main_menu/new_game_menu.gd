extends Control

var DoB := RegEx.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	$CenterContainer/CenteringCon/VBoxContainer/PlayerCount.text = "1"
	$CenterContainer/CenteringCon/Primary/Confirm.text = "Next"
	$CenterContainer/CenteringCon/Primary/NameIN.grab_focus()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_confirm_pressed() -> void:

	DoB.compile("[A-Za-z]\\w")
	var result := DoB.search($CenterContainer/CenteringCon/Primary/DateIN.text)
	if result:
		$CenterContainer/CenteringCon.visible = false
		$"CenterContainer/Pop-Up".visible = true
		$"CenterContainer/Pop-Up/ErrorLabel".text = "Η Ημερομηνία γέννησης να έχει μορφή: 01/01/0001 !"
		return
		
	if $CenterContainer/CenteringCon/Primary/DateIN.text.length() != 10 || $CenterContainer/CenteringCon/Primary/NameIN.text.length() == 0:
		$CenterContainer/CenteringCon.visible = false
		$"CenterContainer/Pop-Up".visible = true
		$"CenterContainer/Pop-Up/ErrorLabel".text = "Παρακαλώ εισάγετε σωστά τα στοιχεία σας!"
		return

	if $CenterContainer/CenteringCon/VBoxContainer/PlayerCount.text == "1":
		PlayerData.player_name_1 = $CenterContainer/CenteringCon/Primary/NameIN.text
		PlayerData.birthdate_1 = $CenterContainer/CenteringCon/Primary/DateIN.text
		$CenterContainer/CenteringCon/VBoxContainer/PlayerCount.text = "2"
		$CenterContainer/CenteringCon/Primary/Confirm.text = "Start!"
		$CenterContainer/CenteringCon/Primary/NameIN.text =''
		$CenterContainer/CenteringCon/Primary/DateIN.text =''
		return

	PlayerData.player_name_2 = $CenterContainer/CenteringCon/Primary/NameIN.text
	PlayerData.birthdate_2 = $CenterContainer/CenteringCon/Primary/DateIN.text

	# Clean up globals before switching to level scene
	Global.before_scene_change()
	get_tree().change_scene_to_file("res://Levels/Lvl1_1.tscn")


func _on_back_pressed() -> void:
	$CenterContainer/CenteringCon/Primary/NameIN.text =''
	$CenterContainer/CenteringCon/Primary/DateIN.text =''
	$CenterContainer/CenteringCon.visible = true
	$"CenterContainer/Pop-Up".visible = false
	return


func _on_back_to_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Menus/main_menu/Menu.tscn");
