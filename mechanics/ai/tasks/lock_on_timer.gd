#*
#* lock_on_timer.gd
#* =============================================================================
#* Timer task that waits for lock-on duration before allowing attack.
#* =============================================================================
#*
@tool
extends BTAction
## Waits for lock-on duration. [br]
## Returns [code]RUNNING[/code] while timer is active. [br]
## Returns [code]SUCCESS[/code] when timer completes.

## Blackboard variable for lock-on timer (float).
@export var lock_on_timer_var: StringName = &"lock_on_timer"

## Lock-on duration in seconds.
@export var lock_on_duration: float = 1.5

func _generate_name() -> String:
	return "Lock On Timer (%.1fs)" % lock_on_duration


func _enter() -> void:
	if not blackboard.has_var(lock_on_timer_var):
		blackboard.set_var(lock_on_timer_var, 0.0)
	blackboard.set_var(lock_on_timer_var, lock_on_duration)


func _tick(delta: float) -> Status:
	var timer: float = blackboard.get_var(lock_on_timer_var, 0.0, false)
	
	# Decrease timer
	timer -= delta
	timer = max(0.0, timer)
	blackboard.set_var(lock_on_timer_var, timer)
	
	# Check if timer completed
	if timer <= 0.0:
		return SUCCESS
	else:
		return RUNNING


func _exit() -> void:
	# Reset timer when task exits
	blackboard.set_var(lock_on_timer_var, 0.0)
