extends Node2D
class_name PlayerStateMachine

var states: Array[State]
var prev_state: State

var current_state: State
	
func _process(delta):
	ChangeState(current_state.Process(delta))
	
func _physics_process(delta):
	ChangeState(current_state.Physics(delta))
	
func _unhandled_input(event):
	ChangeState(current_state.HandleInput(event))
	
func Initialize(_player: Player):
	states = []
	
	for c in get_children():
		if c is State:
			states.append(c)
			
	if states.size() > 0:
		states[0].player = _player
		ChangeState(states[0])
	
func ChangeState(new_state: State):
	if new_state == null or new_state == current_state:
		return
		
	if current_state:
		current_state.Exit()
		
	prev_state = current_state
	current_state = new_state
	current_state.Enter()
