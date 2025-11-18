#*
#* move_toward_sound.gd
#* =============================================================================
#* Alert Level 1: Caution - Moves slowly toward sound from the player.
#* =============================================================================
#*
@tool
extends BTAction
## Moves slowly (0.5x speed) toward sound position. [br]
## Uses most recent check (prioritize sight if both available). [br]
## 1 second cooldown before picking new location. [br]
## Returns [code]RUNNING[/code] while moving. [br]
## Returns [code]SUCCESS[/code] if alert level != 1 (exits early).

## Blackboard variable for alert level (int).
@export var alert_level_var: StringName = &"alert_level"

## Blackboard variable for desired speed (float).
@export var speed_var: StringName = &"speed"

## Blackboard variable for player visibility (bool).
@export var player_visible_var: StringName = &"player_visible"

## Blackboard variable for player audibility (bool).
@export var player_audible_var: StringName = &"player_audible"

## Blackboard variable for sound position (Vector2).
@export var sound_position_var: StringName = &"sound_position"

## Blackboard variable for last sight position (Vector2).
@export var last_sight_position_var: StringName = &"last_sight_position"

## Blackboard variable for investigation cooldown (float).
@export var investigation_cooldown_var: StringName = &"investigation_cooldown"

## Target alert level required for this task (should be 1 for caution).
@export var required_alert_level: int = 1

## Speed multiplier for caution mode (0.5x).
@export var caution_speed_multiplier: float = 0.5

## How close to get to the target position.
@export var arrival_tolerance: float = 30.0

var _target_position: Vector2 = Vector2.ZERO
var _has_target: bool = false


func _generate_name() -> String:
	return "Move Toward Sound"


func _enter() -> void:
	_has_target = false
	_target_position = Vector2.ZERO


func _tick(delta: float) -> Status:
	# Check alert level first - must be at required level to continue
	var alert_level: int = 0
	if blackboard.has_var(alert_level_var):
		alert_level = blackboard.get_var(alert_level_var)
	
	if alert_level != required_alert_level:
		# Alert level changed, return SUCCESS immediately
		return SUCCESS
	
	# Get detection status
	var player_visible: bool = false
	if blackboard.has_var(player_visible_var):
		player_visible = blackboard.get_var(player_visible_var)
	
	var player_audible: bool = false
	if blackboard.has_var(player_audible_var):
		player_audible = blackboard.get_var(player_audible_var)
	
	# Get investigation cooldown
	var investigation_cooldown: float = 0.0
	if blackboard.has_var(investigation_cooldown_var):
		investigation_cooldown = blackboard.get_var(investigation_cooldown_var)
	
	# Decrement cooldown
	if investigation_cooldown > 0.0:
		investigation_cooldown = max(0.0, investigation_cooldown - delta)
		blackboard.set_var(investigation_cooldown_var, investigation_cooldown)
	
	# Determine target position (prioritize sight if both available)
	var target_pos: Vector2 = Vector2.ZERO
	
	if player_visible:
		# Prioritize sight position
		if blackboard.has_var(last_sight_position_var):
			target_pos = blackboard.get_var(last_sight_position_var)
	elif player_audible:
		# Use sound position
		if blackboard.has_var(sound_position_var):
			target_pos = blackboard.get_var(sound_position_var)
	
	if target_pos == Vector2.ZERO:
		# No target available, stop
		agent.move(Vector2.ZERO)
		return RUNNING
	
	# Update target if cooldown expired or no target set
	if not _has_target or (investigation_cooldown <= 0.0 and agent.global_position.distance_to(_target_position) < arrival_tolerance):
		_target_position = target_pos
		_has_target = true
		# Set 1 second cooldown before next target can be picked
		blackboard.set_var(investigation_cooldown_var, 1.0)
	
	# Move toward target
	var distance_to_target: float = agent.global_position.distance_to(_target_position)
	
	if distance_to_target < arrival_tolerance:
		# Reached target, wait for cooldown
		agent.move(Vector2.ZERO)
		return RUNNING
	
	# Get speed and apply multiplier
	var speed: float = 200.0
	if blackboard.has_var(speed_var):
		speed = blackboard.get_var(speed_var)
	
	speed *= caution_speed_multiplier  # 0.5x speed
	
	var direction: Vector2 = agent.global_position.direction_to(_target_position)
	var desired_velocity: Vector2 = direction * speed
	agent.move(desired_velocity)
	agent.update_facing()
	
	return RUNNING

