#*
#* manage_alert_level.gd
#* =============================================================================
#* Manages alert level (0-3) based on awareness thresholds.
#* 0 = Passive, 1 = Caution, 2 = Tracking, 3 = Engaged
#* =============================================================================
#*
@tool
extends BTAction
## Manages the alert level system based on awareness. [br]
## Returns [code]RUNNING[/code] always (doesn't block sequence).

## Blackboard variable that stores the alert level (int: 0-3).
@export var alert_level_var: StringName = &"alert_level"

## Blackboard variable that stores awareness (float, 0-300).
@export var awareness_var: StringName = &"awareness"

## Awareness threshold to reach alert level 1.
@export var awareness_threshold_level_1: float = 100.0

## Awareness threshold to reach alert level 2.
@export var awareness_threshold_level_2: float = 200.0

## Awareness threshold to reach alert level 3.
@export var awareness_threshold_level_3: float = 275.0


func _generate_name() -> String:
	return "Manage Alert Level"


func _enter() -> void:
	# Initialize alert level if not set
	if not blackboard.has_var(alert_level_var):
		blackboard.set_var(alert_level_var, 0)


func _tick(_delta: float) -> Status:
	# Get current alert level
	var alert_level: int = 0
	if blackboard.has_var(alert_level_var):
		alert_level = blackboard.get_var(alert_level_var)
	else:
		blackboard.set_var(alert_level_var, 0)
	
	# Get current awareness
	var awareness: float = 0.0
	if blackboard.has_var(awareness_var):
		awareness = blackboard.get_var(awareness_var)
	
	# Increase alert level based on awareness thresholds
	if awareness > awareness_threshold_level_3 and alert_level < 3:
		alert_level = 3
	elif awareness > awareness_threshold_level_2 and alert_level < 2:
		alert_level = 2
	elif awareness > awareness_threshold_level_1 and alert_level < 1:
		alert_level = 1
	
	# Decrease alert level when awareness drops below thresholds
	# Only decrease if awareness is below the threshold for the current level
	if alert_level == 3 and awareness < awareness_threshold_level_3:
		alert_level = 2
	elif alert_level == 2 and awareness < awareness_threshold_level_2:
		alert_level = 1
	elif alert_level == 1 and awareness < awareness_threshold_level_1:
		alert_level = 0
	
	# Update alert level
	blackboard.set_var(alert_level_var, alert_level)
	
	return RUNNING
