extends Node
@onready var passblock_text : RichTextLabel = $PassblockCounterText

func _ready():
	Global.passblock_count_changed.connect(update_text)
	update_text()

func update_text():
	passblock_text.text = "{0}/{1}".format([Global.passblock_count, Global.passblocks_in_level.size()])
