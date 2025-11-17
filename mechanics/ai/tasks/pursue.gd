#*
#* pursue.gd
#* =============================================================================
#* Pursue task - moves the agent towards a target stored in the blackboard.
#* =============================================================================
#*
@tool
extends BTAction
## Moves the agent towards a target stored in the blackboard. [br]
## Returns [code]RUNNING[/code] while pursuing the target. [br]
## Returns [code]FAILURE[/code] if target is invalid or lost.

## Blackboard variable that stores the target node (Node2D).
@export var target_var: StringName = &"target"

## Blackboard variable that stores desired speed (float).
@export var speed_var: StringName = &"speed"

## Blackboard variable to store current state string.
@export var current_state_var: StringName = &"current_state"

## Maximum distance to maintain from target (0 = pursue until contact).
@export var stop_distance: float = 0.0

## Minimum distance before considering target reached.
@export var arrival_tolerance: float = 10.0

## Blackboard variable for alert level (int).
@export var alert_level_var: StringName = &"alert_level"

## Target alert level required for this task (set to -1 to run at all alert levels).
@export var required_alert_level: int = -1


func _generate_name() -> String:
	return "Pursue  target: %s" % [LimboUtility.decorate_var(target_var)]


func _tick(_delta: float) -> Status:
	# Check alert level if required_alert_level is set (>= 0)
	if required_alert_level >= 0:
		var alert_level: int = 0
		if blackboard.has_var(alert_level_var):
			alert_level = blackboard.get_var(alert_level_var)
		
		if alert_level != required_alert_level:
			# Alert level doesn't match, return SUCCESS to exit early
			return SUCCESS
	
	var target: Node2D = null
	if blackboard.has_var(target_var):
		target = blackboard.get_var(target_var) as Node2D
	
	if not is_instance_valid(target):
		_update_state("No target in blackboard")
		return FAILURE
	
	var to_target: Vector2 = target.global_position - agent.global_position
	var distance: float = to_target.length()
	
	# Check if we've reached the target
	if stop_distance > 0.0 and distance <= stop_distance:
		_update_state("Target reached")
		# Stop moving
		agent.move(Vector2.ZERO)
		return RUNNING
	
	# Check if we're very close (arrival tolerance)
	if distance <= arrival_tolerance:
		_update_state("At target")
		agent.move(Vector2.ZERO)
		agent.update_facing()
		return RUNNING
	
	# Move towards target
	var speed: float = blackboard.get_var(speed_var, 200.0)
	var direction: Vector2 = to_target.normalized()
	var desired_velocity: Vector2 = direction * speed
	
	agent.move(desired_velocity)
	agent.update_facing()
	
	_update_state("Pursuing target (%.0fm)" % distance)
	
	return RUNNING


func _update_state(state: String) -> void:
	if not current_state_var.is_empty():
		blackboard.set_var(current_state_var, state)
