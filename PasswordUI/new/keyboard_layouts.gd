extends Node

var numpad_layout = {
	"name": "numpad",
	"rows": [
		{
			"keys": [
				{"display": "7", "value": "7", "type": "number"},
				{"display": "8", "value": "8", "type": "number"},
				{"display": "9", "value": "9", "type": "number"}
			],
			"key_count": 3
		},
		{
			"keys": [
				{"display": "4", "value": "4", "type": "number"},
				{"display": "5", "value": "5", "type": "number"},
				{"display": "6", "value": "6", "type": "number"}
			],
			"key_count": 3
		},
		{
			"keys": [
				{"display": "1", "value": "1", "type": "number"},
				{"display": "2", "value": "2", "type": "number"},
				{"display": "3", "value": "3", "type": "number"}
			],
			"key_count": 3
		},
		{
			"keys": [
				{"display": "0", "value": "0", "type": "number"},
			],
			"key_count": 1
		}
	]
}

var qwerty_upper_layout = {
	"name": "qwerty_upper",
	"rows": [
		{
			"keys": [
				{"display": "Q", "value": "Q", "type": "letter"},
				{"display": "W", "value": "W", "type": "letter"},
				{"display": "E", "value": "E", "type": "letter"},
				{"display": "R", "value": "R", "type": "letter"},
				{"display": "T", "value": "T", "type": "letter"},
				{"display": "Y", "value": "Y", "type": "letter"},
				{"display": "U", "value": "U", "type": "letter"},
				{"display": "I", "value": "I", "type": "letter"},
				{"display": "O", "value": "O", "type": "letter"},
				{"display": "P", "value": "P", "type": "letter"}
			],
			"key_count": 10
		},
		{
			"keys": [
				{"display": "A", "value": "A", "type": "letter"},
				{"display": "S", "value": "S", "type": "letter"},
				{"display": "D", "value": "D", "type": "letter"},
				{"display": "F", "value": "F", "type": "letter"},
				{"display": "G", "value": "G", "type": "letter"},
				{"display": "H", "value": "H", "type": "letter"},
				{"display": "J", "value": "J", "type": "letter"},
				{"display": "K", "value": "K", "type": "letter"},
				{"display": "L", "value": "L", "type": "letter"}
			],
			"key_count": 9
		},
		{
			"keys": [
				{"display": "Z", "value": "Z", "type": "letter"},
				{"display": "X", "value": "X", "type": "letter"},
				{"display": "C", "value": "C", "type": "letter"},
				{"display": "V", "value": "V", "type": "letter"},
				{"display": "B", "value": "B", "type": "letter"},
				{"display": "N", "value": "N", "type": "letter"},
				{"display": "M", "value": "M", "type": "letter"},
				{"display": "", "value": "", "type": ""},
				{"display": "", "value": "", "type": ""},
			],
			"key_count": 9
		}
	]
}

var qwerty_lower_layout = {
	"name": "qwerty_lower",
	"rows": [
		{
			"keys": [
				{"display": "q", "value": "q", "type": "letter"},
				{"display": "w", "value": "w", "type": "letter"},
				{"display": "e", "value": "e", "type": "letter"},
				{"display": "r", "value": "r", "type": "letter"},
				{"display": "t", "value": "t", "type": "letter"},
				{"display": "y", "value": "y", "type": "letter"},
				{"display": "u", "value": "u", "type": "letter"},
				{"display": "i", "value": "i", "type": "letter"},
				{"display": "o", "value": "o", "type": "letter"},
				{"display": "p", "value": "p", "type": "letter"}
			],
			"key_count": 10
		},
		{
			"keys": [
				{"display": "a", "value": "a", "type": "letter"},
				{"display": "s", "value": "s", "type": "letter"},
				{"display": "d", "value": "d", "type": "letter"},
				{"display": "f", "value": "f", "type": "letter"},
				{"display": "g", "value": "g", "type": "letter"},
				{"display": "h", "value": "h", "type": "letter"},
				{"display": "j", "value": "j", "type": "letter"},
				{"display": "k", "value": "k", "type": "letter"},
				{"display": "l", "value": "l", "type": "letter"}
			],
			"key_count": 9
		},
		{
			"keys": [
				{"display": "", "value": "", "type": ""},
				{"display": "", "value": "", "type": ""},
				{"display": "z", "value": "z", "type": "letter"},
				{"display": "x", "value": "x", "type": "letter"},
				{"display": "c", "value": "c", "type": "letter"},
				{"display": "v", "value": "v", "type": "letter"},
				{"display": "b", "value": "b", "type": "letter"},
				{"display": "n", "value": "n", "type": "letter"},
				{"display": "m", "value": "m", "type": "letter"}

			],
			"key_count": 9
		}
	]
}

var symbols_layout = {
	"name" : "symbols",
	"rows": [
		{
			"keys": [
				{"display": "@", "value": "@", "type": "symbol"},
				{"display": "#", "value": "#", "type": "symbol"},
				{"display": "&", "value": "&", "type": "symbol"},
				{"display": "*", "value": "*", "type": "symbol"},
				{"display": ":", "value": ":", "type": "symbol"},
				{"display": ";", "value": ";", "type": "symbol"},
				{"display": "!", "value": "!", "type": "symbol"},
				{"display": "?", "value": "?", "type": "symbol"},
				{"display": "_", "value": "_", "type": "symbol"},
				{"display": "$", "value": "$", "type": "symbol"},
				{"display": "%", "value": "%", "type": "symbol"},
				{"display": "€", "value": "€", "type": "symbol"},
				{"display": "-", "value": "-", "type": "symbol"}
			],
			"key_count": 13
		}
	]
}

func get_layout(layout_name: String) -> Dictionary:
	match layout_name:
		"numpad":
			return numpad_layout
		"qwerty_upper":
			return qwerty_upper_layout
		"qwerty_lower":
			return qwerty_lower_layout
		"symbols":
			return symbols_layout
		_:
			return numpad_layout
