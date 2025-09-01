extends Node2D
@export var spawn_index:int = 0
@export var player1Spawn:Node2D
@export var player2Spawn:Node2D

func _ready():
	SpawnManager.register_spawn_point(0, spawn_index, player1Spawn)
	SpawnManager.register_spawn_point(1, spawn_index, player2Spawn)
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.name == "Player":  # Adjust condition as needed
		on_collision()

func on_collision():
	if SpawnManager.spawnIndex<spawn_index:
		SpawnManager.spawnIndex=spawn_index
		print("Activated spawn point %d " % [spawn_index])
