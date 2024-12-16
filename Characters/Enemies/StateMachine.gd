class_name StateMachine
extends Node2D
 
@export var current_state: State 
var states: Dictionary = {}
 
func _ready():
	for child in get_children():
		if child is State:
			states[child.name] = child
			child.transitioned.connect(on_child_transitioned)
		if current_state == null:
				current_state = child 
		else:
			push_warning("State machine contains child which is not 'State'")
	
	current_state.Enter()
			
func _process(delta):
	current_state.Update(delta)
		
func _physics_process(delta):
	current_state.Physics_update(delta)
	
func on_child_transitioned(new_state_name: StringName) -> void:
	var new_state = states.get(new_state_name)
	if new_state != null:
		if new_state != current_state:
			current_state.Exit()
			new_state.Enter()
			current_state = new_state
	else:
		push_warning("Called transition on a state that does not exist")
