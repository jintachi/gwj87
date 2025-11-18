#*
#* manage_investigation_cooldown.gd
#* =============================================================================
#* Manages 1 second cooldown for investigation target changes.
#* =============================================================================
#*
@tool
extends BTAction
## Manages investigation cooldown timer. [br]
## Returns [code]RUNNING[/code] always (doesn't block sequence).

## Blackboard variable for investigation cooldown (float).
@export var investigation_cooldown_var: StringName = &"investigation_cooldown"

## Cooldown duration in seconds.
@export var cooldown_duration: float = .2


func _generate_name() -> String:
	return "Manage Investigation Cooldown"


func _enter() -> void:
	# Initialize cooldown if not set
	if not blackboard.has_var(investigation_cooldown_var):
		blackboard.set_var(investigation_cooldown_var, 0.0)


func _tick(delta: float) -> Status:
	# Get current cooldown
	var cooldown: float = 0.0
	if blackboard.has_var(investigation_cooldown_var):
		cooldown = blackboard.get_var(investigation_cooldown_var)
	
	# Decrease cooldown timer
	if cooldown > 0.0:
		cooldown = max(0.0, cooldown - delta)
		blackboard.set_var(investigation_cooldown_var, cooldown)
	
	return RUNNING
