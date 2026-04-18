extends Node
@onready var passblock_progress : ProgressBar = $PassblockProgressBar
@onready var progress_label : Label = $PassblockProgressBar/CountLabel

func _ready():
	Global.passblock_count_changed.connect(update_text)
	update_text()
	print("PassblockCounter initialized. Total in level: ", Global.passblocks_in_level.size())

func update_text():
	var total = Global.passblocks_in_level.size()
	var count = Global.passblock_count
	passblock_progress.max_value = total
	passblock_progress.value = count
	var count_text = "{0}/{1}".format([count, total])
	progress_label.text = count_text
	print("Passblock counter updated: ", count_text)
