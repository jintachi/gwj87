#*
#* wander.gd
#* =============================================================================
#* Wander task - moves to random positions within wander_radius around NodePath waypoints.
#* =============================================================================
#*
@tool
extends BTAction
## Moves to random positions around NodePath waypoints. [br]
## Returns [code]RUNNING[/code] while moving to a waypoint. [br]
## Returns [code]SUCCESS[/code] when reaching a waypoint. [br]
## Returns [code]SUCCESS[/code] if alert level > 0 (exits early).

## Blackboard variable that stores the array of waypoints (Array[Vector2]).
@export var waypoints_var: StringName = &"waypoints"

## Blackboard variable that stores the current waypoint index (int).
@export var current_waypoint_index_var: StringName = &"patrol_index"

## Blackboard variable that stores desired speed (float).
@export var speed_var: StringName = &"speed"

## Blackboard variable for alert level (int).
@export var alert_level_var: StringName = &"alert_level"

## Radius around waypoint to pick random position.
@export var wander_radius: float = 50.0

## How close should the agent be to the target to consider it reached.
@export var tolerance: float = 50.0

var _current_target: Vector2 = Vector2.ZERO
var _has_target: bool = false


func _generate_name() -> String:
	return "Wander  radius: %.0f" % wander_radius


func _enter() -> void:
	_has_target = false
	_current_target = Vector2.ZERO


func _tick(_delta: float) -> Status:
	# Check alert level - exit early if alert level > 0
	var alert_level: int = 0
	if blackboard.has_var(alert_level_var):
		alert_level = blackboard.get_var(alert_level_var)
	
	if alert_level > 0:
		return SUCCESS
	
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
	
	var current_waypoint: Vector2 = waypoints[current_index]
	
	# Pick a new random target if we don't have one or reached the current target
	if not _has_target:
		# Pick random position within wander_radius around current waypoint
		var angle: float = randf() * TAU
		var distance: float = randf() * wander_radius
		_current_target = current_waypoint + Vector2(cos(angle), sin(angle)) * distance
		_has_target = true
	
	var distance_to_target: float = agent.global_position.distance_to(_current_target)
	
	# Check if we've reached the target
	if distance_to_target < tolerance:
		# Move to next waypoint
		current_index = (current_index + 1) % waypoints.size()
		blackboard.set_var(current_waypoint_index_var, current_index)
		_has_target = false  # Pick new random position around next waypoint
		return RUNNING
	
	# Move towards the random target
	var speed: float = 200.0
	if blackboard.has_var(speed_var):
		speed = blackboard.get_var(speed_var)
	
	var direction: Vector2 = agent.global_position.direction_to(_current_target)
	var desired_velocity: Vector2 = direction * speed
	agent.move(desired_velocity)
	agent.update_facing()
	
	return RUNNING
