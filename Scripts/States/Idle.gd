class_name Idle
extends State
@export var enemy : CharacterBody2D
func Enter() -> void:
	pass
	
func Exit() -> void:
	pass
	
func Update(_delta: float) -> void:
	pass
 
func Physics_update(_delta: float) -> void:
	enemy.velocity = Vector2.ZERO
