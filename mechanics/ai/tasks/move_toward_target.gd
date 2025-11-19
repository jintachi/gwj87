#*
#* move_toward_target.gd
#* =============================================================================
#* Alert Level 2: Tracking - Moves toward last known player location at 1.25x speed.
#* =============================================================================
#*
@tool
extends BTAction
## Moves toward last_known_player_location at 1.25x speed. [br]
## Returns [code]RUNNING[/code] while moving. [br]
## Returns [code]SUCCESS[/code] if alert level != 2 (exits early).

## Blackboard variable for alert level (int).
@export var alert_level_var: StringName = &"alert_level"

## Blackboard variable for desired speed (float).
@export var speed_var: StringName = &"speed"

## Blackboard variable for last known player location (Vector2).
@export var last_known_player_location_var: StringName = &"last_known_player_location"

## Target alert level required for this task (should be 2 for tracking).
@export var required_alert_level: int = 2

## Speed multiplier for tracking mode (1.25x).
@export var tracking_speed_multiplier: float = 1.25

## How close to get to the target position.
@export var arrival_tolerance: float = 30.0


func _generate_name() -> String:
	return "Move Toward Target"


func _enter() -> void:
	pass


func _tick(_delta: float) -> Status:
	# Check alert level first - must be at required level to continue
	var alert_level: int = 0
	if blackboard.has_var(alert_level_var):
		alert_level = blackboard.get_var(alert_level_var)
	
	if alert_level != required_alert_level:
		# Alert level changed, return SUCCESS immediately
		return SUCCESS
	
	# Get last known player location
	var target_position: Vector2 = Vector2.ZERO
	if blackboard.has_var(last_known_player_location_var):
		target_position = blackboard.get_var(last_known_player_location_var)
	
	if target_position == Vector2.ZERO:
		# No target available, stop
		agent.move(Vector2.ZERO, _delta)
		return RUNNING
	
	# Move toward target
	var distance_to_target: float = agent.global_position.distance_to(target_position)
	
	if distance_to_target < arrival_tolerance:
		# Reached target
		agent.move(Vector2.ZERO, _delta)
		return RUNNING
	
	# Get speed and apply multiplier
	var speed: float = 200.0
	if blackboard.has_var(speed_var):
		speed = blackboard.get_var(speed_var)
	
	speed *= tracking_speed_multiplier  # 1.25x speed
	
	var direction: Vector2 = agent.global_position.direction_to(target_position)
	agent.move(direction, _delta)
	agent.update_facing()
	
	return RUNNING
