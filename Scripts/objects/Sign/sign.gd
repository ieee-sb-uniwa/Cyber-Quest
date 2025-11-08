extends Node2D


@export var sign_label: String = ""
@onready var sprite: Sprite2D = $Text

func _ready():
		if sign_label != "":
			var tex = ResourceLoader.load(sign_label)
			if tex is Texture2D:
				sprite.texture = tex
			else:
				push_error("Failed to load texture: %s" % sign_label)
