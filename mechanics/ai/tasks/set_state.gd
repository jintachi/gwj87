#*
#* set_state.gd
#* =============================================================================
#* Sets the NPC's current state in the blackboard.
#* =============================================================================
#*
@tool
extends BTAction
## Sets the NPC's state in the blackboard. [br]
## Always returns [code]SUCCESS[/code] after setting the state.

## State name to set (e.g., "Passive", "Alert", "Engaged").
@export var state_name: String = "Passive"

## Blackboard variable to store the state.
@export var state_var: StringName = &"npc_state"


func _generate_name() -> String:
	return "Set State: %s" % state_name


func _enter() -> void:
	blackboard.set_var(state_var, state_name)


func _tick(_delta: float) -> Status:
	# Ensure state is set
	blackboard.set_var(state_var, state_name)
	return SUCCESS
