#*
#* check_alert_level.gd
#* =============================================================================
#* Condition task to check if alert level matches a specific value.
#* =============================================================================
#*
@tool
extends BTAction
## Checks if alert level matches the target level. [br]
## Returns [code]SUCCESS[/code] if alert level matches. [br]
## Returns [code]FAILURE[/code] if alert level doesn't match.

## Blackboard variable that stores the alert level (int: 0-2).
@export var alert_level_var: StringName = &"alert_level"

## Target alert level to check for (0, 1, or 2).
@export var target_level: int = 0


func _generate_name() -> String:
	return "Check Alert Level == %d" % target_level


func _enter() -> void:
	pass


func _tick(_delta: float) -> Status:
	if not blackboard.has_var(alert_level_var):
		blackboard.set_var(alert_level_var, 0)

	var current_level: int = blackboard.get_var(alert_level_var)

	if current_level == target_level:
		return SUCCESS
	else:
		return FAILURE
