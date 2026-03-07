extends Control

var DoB := RegEx.new()
var player_name_1: String
var player_name_2: String
var birth_date_: String
var birthdate_2: String

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
		player_name_1 = $CenterContainer/CenteringCon/Primary/NameIN.text
		birth_date_ = $CenterContainer/CenteringCon/Primary/DateIN.text
		$CenterContainer/CenteringCon/VBoxContainer/PlayerCount.text = "2"
		$CenterContainer/CenteringCon/Primary/Confirm.text = "Start!"
		$CenterContainer/CenteringCon/Primary/NameIN.text =''
		$CenterContainer/CenteringCon/Primary/DateIN.text =''
		return

	player_name_2 = $CenterContainer/CenteringCon/Primary/NameIN.text
	birthdate_2 = $CenterContainer/CenteringCon/Primary/DateIN.text
	var player_names := [player_name_1, player_name_2]
	var birthdates := [birth_date_, birthdate_2]
	# Set new game data
	Controller.on_new_game(player_names, birthdates)

	AudioPlayer.stop_clear()	# Use before loading level to stop menu music
	
	Controller._open_scene("Level_1_1",11)

func _on_back_pressed() -> void:
	$CenterContainer/CenteringCon/Primary/NameIN.text =''
	$CenterContainer/CenteringCon/Primary/DateIN.text =''
	$CenterContainer/CenteringCon.visible = true
	$"CenterContainer/Pop-Up".visible = false
	return

func _on_back_to_menu_pressed() -> void:
	Controller._open_scene("Main_Menu",-1)
