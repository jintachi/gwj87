#*
#* idle.gd
#* =============================================================================
#* Simple idle behavior - agent stands still.
#* =============================================================================
#*
@tool
extends BTAction
## Makes the agent idle (stand still). [br]
## Returns [code]RUNNING[/code] always.

func _generate_name() -> String:
	return "Idle"


func _tick(_delta: float) -> Status:
	agent.move(Vector2.ZERO)
	return RUNNING

