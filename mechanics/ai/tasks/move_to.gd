#*
#* move_to.gd
#* =============================================================================
#* Moves the entity to a target position stored in the blackboard.
#* =============================================================================
#*
@tool
extends BTAction
## Moves toward a target position stored in the blackboard. [br]
## Returns [code]RUNNING[/code] while moving. [br]
## Returns [code]SUCCESS[/code] when the target position is reached. [br]
## Returns [code]FAILURE[/code] if no target position is available.

## Blackboard variable for target position (Vector2).
@export var target_position_var: StringName = &"target_position"

## Blackboard variable for desired speed (float).
@export var speed_var: StringName = &"speed"

## How close to get to the target position before considering it reached.
@export var arrival_tolerance: float = 30.0


func _generate_name() -> String:
	return "Move To"


func _enter() -> void:
	pass


func _tick(_delta: float) -> Status:
	# Get target position from blackboard
	var target_position: Vector2 = Vector2.ZERO
	if blackboard.has_var(target_position_var):
		target_position = blackboard.get_var(target_position_var)
	
	# Get speed from blackboard (with default fallback)
	var speed: float = 200.0
	if blackboard.has_var(speed_var):
		speed = blackboard.get_var(speed_var)
	
	# Check if target is valid
	if target_position == Vector2.ZERO:
		# No target available, stop movement
		# Pass -1.0 as delta to use AI task path (velocity mode)
		agent.move(Vector2.ZERO, -1.0)
		return FAILURE
	
	# Calculate distance to target
	var distance_to_target: float = agent.global_position.distance_to(target_position)
	
	# Check if we've reached the target
	if distance_to_target < arrival_tolerance:
		# Reached target, stop movement
		# Pass -1.0 as delta to use AI task path (velocity mode)
		agent.move(Vector2.ZERO, -1.0)
		return SUCCESS
	
	# Calculate direction and velocity toward target
	var direction: Vector2 = agent.global_position.direction_to(target_position)
	var velocity: Vector2 = direction * speed
	
	# Pass velocity with delta < 0 to use AI task path in flyer_bot.gd
	# This will set self_velocity directly
	agent.move(velocity, -1.0)
	agent.update_facing()
	
	return RUNNING
