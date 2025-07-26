class_name PatrolNav
extends State

@export var chase_state: State

@export var starting_direction : Vector2 = Vector2(0, 1)
@export var enemy : Enemy_nav
#onready is used for variable that need to access the scene tree
@onready var nav_agent:  NavigationAgent2D = $"../../NavigationAgent2D"
@onready var conicalDetectionArea =  $"../../detection_zone/Cone"
@onready var nav_region : NavigationRegion2D = get_tree().get_root().find_child("TileMap", true, false).find_child("NavigationRegion2D", true, false)

var animation_tree : AnimationTree
var state_machine
var direction : Vector2 = starting_direction
var lastRoomIndex :int = -1
var roomSelected: bool
var pathingCompleted: bool

func _ready(): 
	animation_tree = enemy.animation_tree
	state_machine = state_machine

func Enter():
	print("Patrolling Nav")
	#enemy.player_in_zone = false
	#enemy.player_in_cone = false
	#enemy.player_visible = false
	conicalDetectionArea.visible = true
	roomSelected = false;
	pathingCompleted = false;


func Exit():
	roomSelected = false
	pathingCompleted = false

func Physics_update(_delta : float):
	enemy.sprite.set_global_rotation(0)
	if enemy.hunting_targets.size()>0:
		transitioned.emit("ChaseNav")
		return
	if !roomSelected: #CALLED WHEN NEEDED TO SELECT A NEW ROOM
		print("Selecting new path")
		nav_check()
		return
	if nav_agent.is_navigation_finished() && roomSelected == true: #CALLED WHEwN ENEMY TOUCHES PATH FINISH POINT
		roomSelected = false
		pathingCompleted = false
		print("Path Completed")
		return
	if roomSelected && pathingCompleted && nav_agent.get_current_navigation_path().size()>0: #CALLED TO KEEP MOVING ON SAME PATH
		move_towards_next_point(nav_agent.get_next_path_position()) 
	
	#if returns_to_path == false:
		#enemy.path_follow.progress += _delta * enemy.move_speed
	#if enemy.player_in_cone && enemy.player_visible && enemy.hunting_target.visible==true: 
		#if chase_state:
			#transitioned.emit(chase_state)
	
func nav_check() -> void:
	roomSelected = true
	nav_agent.target_position = await get_random_room()

func move_towards_next_point(next_point: Vector2) -> void:
	var current_position = enemy.global_position
	var direction_to_path = (next_point - enemy.global_position).normalized()
	enemy.rotation = direction_to_path.angle()
	var new_velocity = current_position.direction_to(next_point) * enemy.move_speed
	if nav_agent.avoidance_enabled:
		nav_agent.set_velocity(new_velocity)
	else: 
		_on_navigation_agent_2d_velocity_computed(new_velocity)
	enemy.move_and_slide()


func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	enemy.velocity=safe_velocity
	

func get_random_room()->Vector2:
	if(enemy.patrolling_rooms.size()>0):
		while true:
			var roomIndex = randi_range(0, enemy.patrolling_rooms.size()-1)
			if lastRoomIndex != roomIndex || lastRoomIndex == -1 || enemy.patrolling_rooms.size()==1:
				lastRoomIndex = roomIndex
				break
		return await get_random_navigable_point(enemy.patrolling_rooms[lastRoomIndex], 0)
	return enemy.global_position

func get_random_navigable_point(room: Area2D, counter: int) -> Vector2:
	var collision_shape = room.get_node("CollisionShape2D") as CollisionShape2D
	if collision_shape == null:
		print("No CollisionShape2D found in room!")
		return Vector2.ZERO
	var shape = collision_shape.shape
	var extents = shape.extents
	var scale = collision_shape.global_transform.get_scale().abs()
	var top_left = collision_shape.global_position - (extents * scale)
	var size = extents * 2 * scale
	var random_point = Vector2( randf_range(top_left.x, top_left.x + size.x), randf_range(top_left.y, top_left.y + size.y))
	#print(str(random_point))
	if await is_point_navigatable(random_point):
		return random_point
	return await get_random_navigable_point(room, counter)
		
func is_point_navigatable(point: Vector2) -> bool:
	await delay_by_frames(3)
	var nav_map = nav_agent.get_navigation_map()
	#NavigationServer2D.region_set_map(nav_region.get_region_rid(), nav_map)
	print(NavigationServer2D.map_get_regions(nav_map))
	var start = NavigationServer2D.map_get_closest_point(nav_map, enemy.global_position)
	var target = NavigationServer2D.map_get_closest_point(nav_map, point)
	NavigationServer2D.set_debug_enabled(true)
	print(" from: "+str(enemy.global_position) + " to: "+str(point))
	print(" from: "+str(start) + " to: "+str(target))
	var path = NavigationServer2D.map_get_path(nav_map, start, target, false, 3)
	print(path)
	if path.size() > 1:
		print("✅ Target is reachable!")
		pathingCompleted = true
		return true;
	print("❌ Target is NOT reachable.")
	return false;
	
func delay_by_frames(frames: int):
	for i in frames:
		await get_tree().process_frame
