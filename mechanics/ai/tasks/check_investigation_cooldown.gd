#*
#* check_investigation_cooldown.gd
#* =============================================================================
#* Condition task to check if investigation cooldown has expired.
#* =============================================================================
#*
@tool
extends BTAction
## Checks if investigation cooldown has expired (<= 0). [br]
## Returns [code]SUCCESS[/code] if cooldown <= 0 (can set new investigation point). [br]
## Returns [code]FAILURE[/code] if cooldown > 0 (must wait).

## Blackboard variable that stores the investigation cooldown timer (float).
@export var investigation_cooldown_var: StringName = &"investigation_cooldown"


func _generate_name() -> String:
	return "Check Investigation Cooldown"


func _tick(delta: float) -> Status:
	# Decrement cooldown if it exists
	var cooldown: float = 0.0
	if blackboard.has_var(investigation_cooldown_var):
		cooldown = blackboard.get_var(investigation_cooldown_var)
	
	# Decrement cooldown
	if cooldown > 0.0:
		cooldown = max(0.0, cooldown - delta)
		blackboard.set_var(investigation_cooldown_var, cooldown)
		return FAILURE  # Cooldown still active
	
	# Cooldown expired or never set - can set new investigation point
	return SUCCESS

