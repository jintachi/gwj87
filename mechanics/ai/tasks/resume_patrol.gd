#*
#* resume_patrol.gd
#* =============================================================================
#* Resumes patrol from the nearest patrol waypoint after alert level drops to 0.
#* Only runs once when transitioning to level 0.
#* =============================================================================
#*
@tool
extends BTAction
## Finds the nearest patrol waypoint and sets it as the current target. [br]
## Returns [code]SUCCESS[/code] when nearest waypoint is found (only runs once).

## Blackboard variable that stores the array of waypoints (Array[Vector2]).
@export var waypoints_var: StringName = &"waypoints"

## Blackboard variable that stores the current waypoint index (int).
@export var current_waypoint_index_var: StringName = &"patrol_index"

var _has_resumed: bool = false


func _enter() -> void:
	_has_resumed = false


func _tick(_delta: float) -> Status:
	# Only run once per entry
	if _has_resumed:
		return SUCCESS
	
	var waypoints: Array = []
	if blackboard.has_var(waypoints_var):
		waypoints = blackboard.get_var(waypoints_var)
	
	if waypoints.is_empty():
		return FAILURE
	
	# Find nearest waypoint
	var nearest_index: int = 0
	var nearest_distance: float = INF
	
	for i in range(waypoints.size()):
		var waypoint: Vector2 = waypoints[i]
		var distance: float = agent.global_position.distance_to(waypoint)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_index = i
	
	# Set current waypoint index to nearest
	blackboard.set_var(current_waypoint_index_var, nearest_index)
	print("Resume Patrol: Set to nearest waypoint %d (distance: %.0f)" % [nearest_index, nearest_distance])
	_has_resumed = true
	
	return SUCCESS

