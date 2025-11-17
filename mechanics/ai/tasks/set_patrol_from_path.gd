#*
#* set_patrol_from_path.gd
#* =============================================================================
#* Behavior tree task to set patrol waypoints from a Path2D.
#* =============================================================================
#*
@tool
extends BTAction
## Reads a Path2D and sets patrol waypoints in the blackboard. [br]
## Returns [code]SUCCESS[/code] if waypoints were set. [br]
## Returns [code]FAILURE[/code] if Path2D is invalid or not found.

## Path to the Path2D node (NodePath or StringName).
## Can be a direct path or a blackboard variable name.
@export var path_node_var: StringName = &"patrol_path"

## Number of waypoints to sample from the path.
@export var waypoint_count: int = 8

## Blackboard variable that stores the waypoints array.
@export var waypoints_var: StringName = &"waypoints"


func _generate_name() -> String:
	return "Set Patrol From Path  path: %s  count: %d" % [
		LimboUtility.decorate_var(path_node_var),
		waypoint_count
	]


func _tick(_delta: float) -> Status:
	var path_node: Path2D
	
	# Try to get Path2D from blackboard variable
	if blackboard.has_var(path_node_var):
		var value = blackboard.get_var(path_node_var)
		if value is NodePath:
			path_node = agent.get_node_or_null(value) as Path2D
		elif value is StringName or value is String:
			path_node = agent.get_node_or_null(value) as Path2D
		elif value is Path2D:
			path_node = value
	else:
		# Fail Out
		print("Unable to get path patrol!")
		#path_node = agent.get_node_or_null(path_node_var) as Path2D
	
	if not is_instance_valid(path_node):
		return FAILURE
	
	var curve: Curve2D = path_node.curve
	if not curve:
		return FAILURE
	
	var waypoints: Array[Vector2] = []
	
	# Sample points along the path
	var path_length: float = curve.get_baked_length()
	if path_length <= 0.0:
		return FAILURE
	
	var sample_count: int = max(2, waypoint_count)
	
	for i in range(sample_count):
		var offset: float = (i / float(sample_count - 1)) * path_length
		var point: Vector2 = curve.sample_baked(offset)
		
		# Convert to global position
		if path_node.get_parent():
			point = path_node.to_global(point)
		else:
			point = path_node.global_position + point
		
		waypoints.append(point)
	
	# Set waypoints in blackboard
	blackboard.set_var(waypoints_var, waypoints)
	blackboard.set_var(&"patrol_index", 0)
	
	return SUCCESS
