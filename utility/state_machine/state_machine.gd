## A simple, but flexible StateMachine.
class_name StateMachine extends Node

#region Variables
@export var initial_state: State = null

## Defines the current state by either grabbing the first child or if [property initial_state] is set.
@onready var state: State = (func _get_initial_state() -> State:
	return initial_state if initial_state != null else get_child(0)
).call()
#endregion

#region Built-Ins
func _ready() -> void:
	for state_node: State in find_children("*", "State"):
		state_node.finished.connect(_transition_to_next_state)
	
	await owner.ready
	state.enter("")

func _process(delta: float) -> void:
	state.update(delta)

func _physics_process(delta: float) -> void:
	state.physics_update(delta)

func _unhandled_input(event: InputEvent) -> void:
	state.handle_input(event)
#endregion

#region Helpers
## Handles transitioning between [property state] and [param target_state_path]. Can also pass a
## dictionary [param data] to provide additional information to the new state.
func _transition_to_next_state(target_state_path: String, data := {}) -> void:
	if not has_node(target_state_path):
		printerr(owner.name + ": Trying to transition to state " + target_state_path + " but it does not exist.")
		return
	
	var previous_state_path := state.name
	state.exit()
	state = get_node(target_state_path)
	state.enter(previous_state_path, data)
#endregion
