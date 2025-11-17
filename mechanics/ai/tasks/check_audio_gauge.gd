#*
#* check_audio_gauge.gd
#* =============================================================================
#* Checks if audio gauge is at 1.0 (ready to investigate).
#* =============================================================================
#*
@tool
extends BTAction
## Checks if audio gauge has reached 1.0 and cooldown has expired. [br]
## Returns [code]SUCCESS[/code] if gauge >= 1.0 and not on cooldown. [br]
## Returns [code]FAILURE[/code] otherwise.

## Blackboard variable that stores the audio detection gauge (0.0-1.0).
@export var audio_gauge_var: StringName = &"audio_gauge"

## Blackboard variable that stores investigation cooldown timer.
@export var investigation_cooldown_var: StringName = &"investigation_cooldown"


func _generate_name() -> String:
	return "Check Audio Gauge >= 1.0"


func _tick(delta: float) -> Status:
	var gauge: float = 0.0
	if blackboard.has_var(audio_gauge_var):
		gauge = blackboard.get_var(audio_gauge_var)
	
	# Check cooldown
	var cooldown: float = 0.0
	if blackboard.has_var(investigation_cooldown_var):
		cooldown = blackboard.get_var(investigation_cooldown_var)
	if cooldown > 0.0:
		cooldown = max(0.0, cooldown - delta)
		blackboard.set_var(investigation_cooldown_var, cooldown)
		return FAILURE
	
	if gauge >= 1.0:
		return SUCCESS
	
	return FAILURE
