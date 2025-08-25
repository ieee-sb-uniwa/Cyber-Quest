extends CanvasLayer

var SAVE_GAME_PATH = "user://save_data.tres"
@export var player1 = $"../Player"
@export var player2 = $"../Player2"

func _save():
	var data = SaveData.new()
	data.player1_pos = player1.global_position
	data.player1_velocity = player1.velocity
	
	data.player2_pos = player2.global_position
	data.player1_velocity = player2.velocity
	
	ResourceSaver.save(data, SAVE_GAME_PATH) #.tres for readable text format, .res for binary format

func _load():
	var data = ResourceLoader.load(SAVE_GAME_PATH) as SaveData
	player1.global_position = data.player1_pos
	player1.velocity = data.player1_velocity
	
	player2.global_position = data.player2_pos
	player2.velocity = data.player2_velocity
