extends Control

var DoB := RegEx.new()
var player_name_1: String
var player_name_2: String
var birth_date_: String
var birthdate_2: String

# Called when the node enters the scene tree for the first time.
func _ready():
	$CenterContainer/Menu/InputForm/NameIN.grab_focus()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_confirm_pressed() -> void:

	DoB.compile("[A-Za-z]\\w")
	var result := DoB.search($CenterContainer/Menu/InputForm/DateIN.text)
	if result:
		$CenterContainer/Menu.visible = false
		$"CenterContainer/Pop-Up".visible = true
		$"CenterContainer/Pop-Up/ErrorLabel".text = "Η Ημερομηνία γέννησης να έχει μορφή: 01/01/0001 !"
		return
		
	if $CenterContainer/Menu/InputForm/DateIN.text.length() != 10 || $CenterContainer/Menu/InputForm/NameIN.text.length() == 0:
		$CenterContainer/Menu.visible = false
		$"CenterContainer/Pop-Up".visible = true
		$"CenterContainer/Pop-Up/ErrorLabel".text = "Παρακαλώ εισάγετε σωστά τα στοιχεία σας!"
		return

	if $CenterContainer/Menu/PlayerLabel.text.contains("1"):
		player_name_1 = $CenterContainer/Menu/InputForm/NameIN.text
		birth_date_ = $CenterContainer/Menu/InputForm/DateIN.text
		$CenterContainer/Menu/PlayerLabel.text = "Παίκτης 2"
		$CenterContainer/Menu/Buttons/Confirm.text = "Ξεκίνα!"
		$CenterContainer/Menu/InputForm/NameIN.text =''
		$CenterContainer/Menu/InputForm/DateIN.text =''
		return

	player_name_2 = $CenterContainer/Menu/InputForm/NameIN.text
	birthdate_2 = $CenterContainer/Menu/InputForm/DateIN.text
	var player_names := [player_name_1, player_name_2]
	var birthdates := [birth_date_, birthdate_2]
	# Set new game data
	Global.on_new_game(player_names, birthdates)

	# Clean up globals before switching to level scene
	Global.before_scene_change()
	# Save the game before starting
	Global.save_game()
	AudioPlayer.stop_clear()	# Use before loading level to stop menu music
	get_tree().change_scene_to_file("res://Levels/Lvl1_1.tscn")

func _on_back_pressed() -> void:
	$CenterContainer/Menu/InputForm/NameIN.text =''
	$CenterContainer/Menu/InputForm/DateIN.text =''
	$CenterContainer/Menu.visible = true
	$"CenterContainer/Pop-Up".visible = false
	return

func _on_back_to_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Menus/main_menu/Menu.tscn");
