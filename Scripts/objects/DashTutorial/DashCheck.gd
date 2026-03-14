extends Node

var players_in_dashing_area: Array = []
var players_in_respawn_area: Array = []

@onready var collider = $StaticBody2D/Collision
@onready var death_timer = $DeathTimer

func _physics_process(_delta):
	if players_in_dashing_area.size() > 0:
		for player in players_in_dashing_area:
			var dash_node = player.get_node("Dash")
			if dash_node and dash_node.is_dashing():
				collider.disabled = true
			else:
				collider.disabled = false
				
		for player in players_in_respawn_area:
			var dash_node = player.get_node("Dash")
			if dash_node and not dash_node.is_dashing():
				player.fall_down = true
				player.P_collission.disabled = true
				death_timer.start()

#Check if the player is dashing and is in the respawn area
func _on_dash_check_body_entered(body):
	if body.is_in_group("Player"):
		players_in_dashing_area.append(body)

func _on_dash_check_body_exited(body):
	if body.is_in_group("Player"):
		players_in_dashing_area.erase(body)
		print("player left the check")

func _on_body_entered(body):
	if body.is_in_group("Player"):
		players_in_respawn_area.append(body)

func _on_body_exited(body):
	if body.is_in_group("Player"):
		players_in_respawn_area.erase(body)


func _on_death_timer_timeout() -> void:
	SpawnManager.respawn_players()
