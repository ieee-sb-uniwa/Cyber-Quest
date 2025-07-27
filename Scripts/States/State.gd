class_name State
extends Node
 
signal transitioned(new_state_name: StringName)
 
func Enter() -> void:
	emit_signal("transitioned", "NextState")
	
func Exit() -> void:
	pass
	
func Update(_delta: float) -> void:
	pass
 
func Physics_update(_delta: float) -> void:
	pass
