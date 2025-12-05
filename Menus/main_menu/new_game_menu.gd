extends Control

var DoB := RegEx.new()
var player_name_1: String
var player_name_2: String
var birth_date_: String
var birthdate_2: String

@onready var numpad_checkbox = $CenterContainer/CenteringCon/NumpadCheckBox  # Προσθήκη αναφοράς

# Called when the node enters the scene tree for the first time.
func _ready():
	$CenterContainer/CenteringCon/VBoxContainer/PlayerCount.text = "1"
	$CenterContainer/CenteringCon/Primary/Confirm.text = "Next"
	$CenterContainer/CenteringCon/Primary/NameIN.grab_focus()
	
	# Σύνδεση του checkbox με την συνάρτηση
	if numpad_checkbox:
		numpad_checkbox.toggled.connect(_on_numpad_toggled)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

# Συνάρτηση για το checkbox του numpad
func _on_numpad_toggled(button_pressed: bool):
	Global.has_numpad = button_pressed
	print("Numpad setting: ", Global.has_numpad)

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
		# Εμφάνιση του checkbox για το numpad μόνο όταν εισάγουμε τον 2ο παίκτη
		if numpad_checkbox:
			numpad_checkbox.visible = true
		return

	player_name_2 = $CenterContainer/CenteringCon/Primary/NameIN.text
	birthdate_2 = $CenterContainer/CenteringCon/Primary/DateIN.text
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
	$CenterContainer/CenteringCon/Primary/NameIN.text =''
	$CenterContainer/CenteringCon/Primary/DateIN.text =''
	$CenterContainer/CenteringCon.visible = true
	$"CenterContainer/Pop-Up".visible = false
	return

func _on_back_to_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Menus/main_menu/Menu.tscn")
