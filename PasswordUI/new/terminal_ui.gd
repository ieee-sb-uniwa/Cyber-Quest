extends Control

@onready var display_text: RichTextLabel = $DisplayScreen/OutputText
@onready var keyboard_manager = $KeyboardContainer/KeyboardLayout
@onready var shift_toggle: Button = $KeyboardContainer/ShiftToggle
@onready var numpad_bg: Control = $KeyboardContainer/NumpadBackground
@onready var letters_bg: Control = $KeyboardContainer/LettersBackground
@onready var symbols_bg: Control = $KeyboardContainer/SymbolsBackground
@export var hasNum : bool = true
@export var hasLetters : bool = false
@export var hasSymbols : bool = false

var current_level: int = 3 # Hard coded for testing full terminal

func _ready():
	shift_toggle.toggled.connect(_on_shift_toggled)
	setup_level(current_level)

func setup_level(level: int):
	current_level = level
	
	numpad_bg.visible = false
	letters_bg.visible = false
	symbols_bg.visible = false
	
	match level: #To be swapped with inventory slots
		1:
			keyboard_manager.setup_level_layouts(1)
			$KeyboardContainer/ShiftToggle.visible = false
			numpad_bg.visible = true
			
		2:
			keyboard_manager.setup_level_layouts(2)
			$KeyboardContainer/ShiftToggle.visible = true
			numpad_bg.visible = true
			letters_bg.visible = true
			
		3:
			keyboard_manager.setup_level_layouts(3)
			$KeyboardContainer/ShiftToggle.visible = true
			numpad_bg.visible = true
			letters_bg.visible = true
			symbols_bg.visible = true


func _on_shift_toggled(button_pressed: bool):
	keyboard_manager.is_uppercase = button_pressed
