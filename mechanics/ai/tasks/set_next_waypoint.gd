#*
#* set_next_waypoint.gd
#* =============================================================================
#* Sets the next waypoint from the waypoints array as the target position.
#* =============================================================================
#*
@tool
extends BTAction
## Sets the next waypoint as target position for movement. [br]
## Returns [code]SUCCESS[/code] when a waypoint is set. [br]
## Returns [code]FAILURE[/code] if no waypoints are available.

## Blackboard variable that stores the array of waypoints (Array[Vector2]).
@export var waypoints_var: StringName = &"waypoints"

## Blackboard variable that stores the current waypoint index (int).
@export var current_waypoint_index_var: StringName = &"patrol_index"

## Blackboard variable for target position (Vector2).
@export var target_position_var: StringName = &"target_position"


func _generate_name() -> String:
	return "Set Next Waypoint"


func _tick(_delta: float) -> Status:
	# Get waypoints from blackboard
	var waypoints: Array = []
	if blackboard.has_var(waypoints_var):
		waypoints = blackboard.get_var(waypoints_var)
	
	if waypoints.is_empty():
		return FAILURE
	
	# Initialize patrol index if not set
	if not blackboard.has_var(current_waypoint_index_var):
		blackboard.set_var(current_waypoint_index_var, 0)
	
	var current_index: int = 0
	if blackboard.has_var(current_waypoint_index_var):
		current_index = blackboard.get_var(current_waypoint_index_var)
	
	# Ensure index is valid
	if current_index < 0 or current_index >= waypoints.size():
		current_index = 0
		blackboard.set_var(current_waypoint_index_var, 0)
	
	# Get current waypoint
	var current_waypoint: Vector2 = waypoints[current_index]
	
	# Set as target position
	blackboard.set_var(target_position_var, current_waypoint)
	
	return SUCCESS

