#*
#* increment_waypoint_index.gd
#* =============================================================================
#* Increments the waypoint index to move to the next waypoint.
#* =============================================================================
#*
@tool
extends BTAction
## Increments the waypoint index. [br]
## Returns [code]SUCCESS[/code] after incrementing.

## Blackboard variable that stores the array of waypoints (Array[Vector2]).
@export var waypoints_var: StringName = &"waypoints"

## Blackboard variable that stores the current waypoint index (int).
@export var current_waypoint_index_var: StringName = &"patrol_index"


func _generate_name() -> String:
	return "Increment Waypoint Index"


func _tick(_delta: float) -> Status:
	# Get waypoints to know the size
	var waypoints: Curve2D = blackboard.get_var(waypoints_var)
	
	if waypoints.point_count == 0:
		return FAILURE
	
	# Get current index
	var current_index: int = 0
	if blackboard.has_var(current_waypoint_index_var):
		current_index = blackboard.get_var(current_waypoint_index_var)
	
	# Increment and wrap around
	current_index = (current_index + 1) % waypoints.get_baked_points().size()
	blackboard.set_var(current_waypoint_index_var, current_index)
	
	return SUCCESS
