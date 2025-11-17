extends Node
class_name SaveData

const SAVE_FILE := "user://savegame.json"

func save_game():
	var data = {
		"player_name_1": PlayerData.player_name_1,
		"birthdate_1": PlayerData.birthdate_1,
		"player_name_2":PlayerData.player_name_2,
		"birthdate_2": PlayerData.birthdate_2,		
		"level": PlayerData.level,
		"inv_slot": PlayerData.inv_slot,
		"isTutorial": Global.isTutorial
	}
	var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))
		file.close()
		print("Data saved: "+ str(data))

func load_game() ->bool:
	if not FileAccess.file_exists(SAVE_FILE):
		print("Loading failed")
		return false

	var file = FileAccess.open(SAVE_FILE, FileAccess.READ)
	var text = file.get_as_text()
	file.close()

	var result = JSON.parse_string(text)
	if typeof(result) == TYPE_DICTIONARY:
		PlayerData.player_name_1 = result.get("player_name_1", "")
		PlayerData.birthdate_1 = result.get("birthdate_1", "")
		PlayerData.player_name_2 = result.get("player_name_2", "")
		PlayerData.birthdate_2 = result.get("birthdate_2", "")
		PlayerData.level = result.get("level", 0)
		PlayerData.inv_slot = result.get("inv_slot", 0)
		Global.isTutorial = result.get("isTutorial", true)
		return true
	return false
