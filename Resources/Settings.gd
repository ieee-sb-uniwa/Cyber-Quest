extends Node

const CONFIG_PATH := "user://settings.cfg"
const SCHEME_NO_NUMPAD := "no_numpad"
const SCHEME_NUMPAD := "numpad"

const P2_SCHEMES := {
	SCHEME_NO_NUMPAD: {
		"move_up_p2": KEY_I,
		"move_down_p2": KEY_K,
		"move_right_p2": KEY_L,
		"move_left_p2": KEY_J,
		"Interact_p2": KEY_N,
		"Dash_p2": KEY_M,
	},
	SCHEME_NUMPAD: {
		"move_up_p2": KEY_KP_8,
		"move_down_p2": KEY_KP_5,
		"move_right_p2": KEY_KP_6,
		"move_left_p2": KEY_KP_4,
		"Interact_p2": KEY_KP_0,
		"Dash_p2": KEY_KP_ENTER,
	},
}

var p2_control_scheme: String = SCHEME_NO_NUMPAD

func _ready() -> void:
	load_settings()
	apply_p2_control_scheme()

func set_p2_control_scheme(scheme: String) -> void:
	if not P2_SCHEMES.has(scheme):
		return
	p2_control_scheme = scheme
	apply_p2_control_scheme()
	save_settings()

func apply_p2_control_scheme() -> void:
	var keys: Dictionary = P2_SCHEMES[p2_control_scheme]
	for action_name in keys:
		InputMap.action_erase_events(action_name)
		var event := InputEventKey.new()
		event.physical_keycode = keys[action_name]
		InputMap.action_add_event(action_name, event)

func load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(CONFIG_PATH) == OK:
		p2_control_scheme = config.get_value("controls", "p2_scheme", SCHEME_NO_NUMPAD)

func save_settings() -> void:
	var config := ConfigFile.new()
	config.load(CONFIG_PATH)
	config.set_value("controls", "p2_scheme", p2_control_scheme)
	config.save(CONFIG_PATH)