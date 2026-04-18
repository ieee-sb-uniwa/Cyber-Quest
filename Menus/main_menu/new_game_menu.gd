extends Control

var date_of_birth := RegEx.new()
var greek_letters := RegEx.new()
var player_name_1: String
var player_name_2: String
var birth_date_: String
var birthdate_2: String

@onready var name_input: LineEdit = $CenterContainer/Menu/InputForm/NameIN
@onready var date_input: LineEdit = $CenterContainer/Menu/InputForm/DateIN
@onready var menu_container: Control = $CenterContainer/Menu
@onready var popup: Control = $"CenterContainer/Pop-Up"
@onready var error_label: Label = $"CenterContainer/Pop-Up/ErrorLabel"
@onready var player_label: Label = $CenterContainer/Menu/PlayerLabel
@onready var confirm_button: Button = $CenterContainer/Menu/Buttons/Confirm

# Called when the node enters the scene tree for the first time.
func _ready():
	name_input.grab_focus()
	greek_letters.compile("[Α-Ωα-ω]")
	date_of_birth.compile("[A-Za-z]\\w")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func show_error(message: String) -> void:
	menu_container.visible = false
	popup.visible = true
	error_label.text = message

func _on_confirm_pressed() -> void:

	# Check for Greek letters in name
	var greek_check := greek_letters.search(name_input.text)
	if greek_check:
		show_error("Το όνομα δεν μπορεί να περιέχει ελληνικά γράμματα!")
		return
	
	var result := date_of_birth.search(date_input.text)
	if result:
		show_error("Η Ημερομηνία γέννησης να έχει μορφή: 01/01/0001 !")
		return
		
	if date_input.text.length() != 10 || name_input.text.length() == 0:
		show_error("Παρακαλώ εισάγετε σωστά τα στοιχεία σας!")
		return

	if player_label.text.contains("1"):
		player_name_1 = name_input.text
		birth_date_ = date_input.text
		player_label.text = "Παίκτης 2"
		confirm_button.text = "Ξεκίνα!"
		name_input.text = ''
		date_input.text = ''
		return

	player_name_2 = name_input.text
	birthdate_2 = date_input.text
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
	name_input.text = ''
	date_input.text = ''
	menu_container.visible = true
	popup.visible = false
	return

func _on_back_to_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Menus/main_menu/Menu.tscn");
