extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	var canLoad = Global.saveData.load_game()
	if canLoad:
		$CenterVbox/VBoxContainer/N1.text = "Player 1: " + PlayerData.player_name_1 + "\n Player 2:" + PlayerData.player_name_2
	$VBoxContainer2/BacktoMenu.grab_focus();
	print(get_tree().get_current_scene())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_backto_menu_pressed():
	get_tree().change_scene_to_file("res://Menus/main_menu/Menu.tscn");


func _on_n_1_pressed() -> void:
	@warning_ignore("integer_division")
	print("res://Levels/Lvl" + str(floor(PlayerData.level/10),'_', PlayerData.level%10, ".tscn"))
	@warning_ignore("integer_division")
	get_tree().change_scene_to_file("res://Levels/Lvl" + str(floor(PlayerData.level/10),'_', PlayerData.level%10, ".tscn"))


func _on_n_2_pressed() -> void:
	pass # Replace with function body.


func _on_n_3_pressed() -> void:
	pass # Replace with function body.
