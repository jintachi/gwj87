#*
#* check_awareness_300.gd
#* =============================================================================
#* Condition task to check if awareness is >= 300.
#* =============================================================================
#*
@tool
extends BTAction
## Checks if awareness is >= 300. [br]
## Returns [code]SUCCESS[/code] if awareness >= 300. [br]
## Returns [code]FAILURE[/code] if awareness < 300.

## Blackboard variable that stores awareness (float: 0-300).
@export var awareness_var: StringName = &"awareness"

## Minimum awareness threshold (default 300).
@export var awareness_threshold: float = 300.0


func _generate_name() -> String:
	return "Check Awareness >= %.0f" % awareness_threshold


func _enter() -> void:
	pass


func _tick(_delta: float) -> Status:
	var awareness: float = blackboard.get_var(awareness_var, 0.0, false)
	
	if awareness >= awareness_threshold:
		if awareness > 270 :
			agent.lock_on_sound.play()
		else : 
			agent.lock_on_sound.stop()
		return SUCCESS
	else:
		return FAILURE
