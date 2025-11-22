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
	# Get waypoints from blackboard (Array[Vector2])
	var waypoints: Variant = blackboard.get_var(waypoints_var, null, false)
	
	# Check if waypoints is valid and not empty
	if waypoints == null or not waypoints is Array or waypoints.is_empty():
		return FAILURE
	
	# Cast to Array for type safety
	var waypoints_array: Array = waypoints as Array
	
	# Get current index
	var current_index: int = 0
	if blackboard.has_var(current_waypoint_index_var):
		current_index = blackboard.get_var(current_waypoint_index_var)
	
	# Increment and wrap around
	current_index = (current_index + 1) % waypoints_array.size()
	blackboard.set_var(current_waypoint_index_var, current_index)
	
	return SUCCESS
