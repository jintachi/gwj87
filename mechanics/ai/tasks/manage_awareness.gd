#*
#* manage_awareness.gd
#* =============================================================================
#* Manages awareness value (0-300 max) based on detection.
#* Handles awareness decay and alert level 3 timer.
#* =============================================================================
#*
@tool
extends BTAction
## Manages the awareness system. [br]
## Returns [code]RUNNING[/code] always (doesn't block sequence).

## Blackboard variable that stores awareness (float, 0-300).
@export var awareness_var: StringName = &"awareness"

## Blackboard variable for awareness decay timer (float).
@export var awareness_decay_timer_var: StringName = &"awareness_decay_timer"

## Blackboard variable for player visibility (bool).
@export var player_visible_var: StringName = &"player_visible"

## Blackboard variable for player audibility (bool).
@export var player_audible_var: StringName = &"player_audible"

## Blackboard variable for alert level (int).
@export var alert_level_var: StringName = &"alert_level"

## Blackboard variable for alert level 3 timer (float).
@export var alert_level_3_timer_var: StringName = &"alert_level_3_timer"

## Maximum awareness value (hard cap).
@export var max_awareness: float = 300.0

## Decay rate when awareness is below 200 (per second).
@export var decay_rate_below_200: float = 5.0

## Decay rate when awareness is above 200 (per second).
@export var decay_rate_above_200: float = 10.0

## Time in seconds before decay starts after last detection.
@export var decay_start_delay: float = 2.0

## Time in seconds for alert level 3 awareness timer.
@export var alert_level_3_timer_duration: float = 10.0


func _generate_name() -> String:
	return "Manage Awareness"


func _enter() -> void:
	# Initialize awareness if not set
	#if not blackboard.has_var(awareness_var):
		blackboard.set_var(awareness_var, 0.0)
	#if not blackboard.has_var(awareness_decay_timer_var):
		blackboard.set_var(awareness_decay_timer_var, 0.0)
	#if not blackboard.has_var(alert_level_3_timer_var):
		blackboard.set_var(alert_level_3_timer_var, 0.0)


func _tick(delta: float) -> Status:
	# Get current awareness
	var awareness: float = 0.0	
	awareness = blackboard.get_var(awareness_var)
	
	var alert_level: int = blackboard.get_var(alert_level_var, 0, false)
	var is_visible: bool = blackboard.get_var(player_visible_var, false, false)
	var is_audible: bool = blackboard.get_var(player_audible_var, false, false)
	
	# Alert Level 3 special handling: Awareness stays at max for 10 seconds
	if alert_level == 3:
		var alert_3_timer: float = blackboard.get_var(alert_level_3_timer_var, 0.0, false)
		
		# Reset timer if player is seen or heard
		if is_visible or is_audible:
			alert_3_timer = alert_level_3_timer_duration
			blackboard.set_var(alert_level_3_timer_var, alert_3_timer)
			# Keep awareness at max
			awareness = max_awareness
		else:
			# Decrement timer
			alert_3_timer -= delta
			blackboard.set_var(alert_level_3_timer_var, alert_3_timer)
			# Keep awareness at max while timer is active
			if alert_3_timer > 0.0:
				awareness = max_awareness
			# Once timer expires, allow normal decay
		
		blackboard.set_var(awareness_var, awareness)
		return RUNNING
	
	# For alert levels 0-2: Normal decay system
	var decay_timer: float = blackboard.get_var(awareness_decay_timer_var, 0.0, false)
	
	# Reset decay timer if player is seen or heard
	if is_visible or is_audible:
		decay_timer = 0.0
		blackboard.set_var(awareness_decay_timer_var, decay_timer)
	else:
		# Increment decay timer
		decay_timer += delta
		blackboard.set_var(awareness_decay_timer_var, decay_timer)
	
	# Apply decay if timer has passed the delay
	if decay_timer >= decay_start_delay:
		var decay_rate: float
		if awareness < 200.0:
			decay_rate = decay_rate_below_200
		else:
			decay_rate = decay_rate_above_200
		
		awareness -= decay_rate * delta
		awareness = max(0.0, awareness)
	
	# Clamp awareness to max
	awareness = min(awareness, max_awareness)
	
	# Update blackboard
	blackboard.set_var(awareness_var, awareness)
	
	return RUNNING
