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
	print("Check Alert Level: Task ENTERED - checking for level %d" % target_level)


func _tick(_delta: float) -> Status:
	# Debug: Verify task is running - ALWAYS tick this task
	if not has_meta("tick_count"):
		set_meta("tick_count", 0)
	var tick_count: int = get_meta("tick_count")
	tick_count += 1
	set_meta("tick_count", tick_count)
	
	# Always print first 20 ticks, then every 60 ticks
	if tick_count <= 20 or tick_count % 60 == 0:
		print("Check Alert Level (target=%d): _tick() #%d" % [target_level, tick_count])

	if not blackboard.has_var(alert_level_var):
		blackboard.set_var(alert_level_var, 0)

	var current_level: int = blackboard.get_var(alert_level_var)

	# Debug: Print check result frequently
	var debug_tick: int = int(Time.get_ticks_msec() / 2000)  # Every 2 seconds
	if tick_count <= 20 or debug_tick != get_meta("last_debug_tick", -1):
		set_meta("last_debug_tick", debug_tick)
		var matches: bool = (current_level == target_level)
		print("Check Alert Level: current=%d, target=%d, match=%s (tick #%d)" % [
			current_level, target_level, matches, tick_count
		])

	if current_level == target_level:
		return SUCCESS
	else:
		return FAILURE
