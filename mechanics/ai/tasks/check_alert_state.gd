#*
#* check_alert_state.gd
#* =============================================================================
#* Checks if NPC should be in Alert state (investigating sound/position).
#* Also checks if should transition from Passive to Alert based on audio gauge.
#* =============================================================================
#*
@tool
extends BTAction
## Checks if the NPC should be in Alert state. [br]
## Returns [code]SUCCESS[/code] if there's a sound position to investigate. [br]
## Returns [code]FAILURE[/code] if nothing to investigate.

## Blackboard variable that stores the sound position (Vector2).
@export var sound_position_var: StringName = &"sound_position"

## Blackboard variable that stores the audio gauge (0.0-1.0).
@export var audio_gauge_var: StringName = &"audio_gauge"

## Blackboard variable that stores investigation cooldown timer.
@export var investigation_cooldown_var: StringName = &"investigation_cooldown"

## Blackboard variable that stores current NPC state.
@export var npc_state_var: StringName = &"npc_state"


func _generate_name() -> String:
	return "Check Alert State"


func _tick(delta: float) -> Status:
	# Check cooldown
	var cooldown: float = 0.0
	if blackboard.has_var(investigation_cooldown_var):
		cooldown = blackboard.get_var(investigation_cooldown_var)
	
	if cooldown > 0.0:
		cooldown = max(0.0, cooldown - delta)
		blackboard.set_var(investigation_cooldown_var, cooldown)
		return FAILURE
	
	# Check if audio gauge is full (ready to investigate)
	var gauge: float = 0.0
	if blackboard.has_var(audio_gauge_var):
		gauge = blackboard.get_var(audio_gauge_var)
	
	if gauge >= 1.0:
		# Check if we have a sound position
		var sound_pos: Vector2 = Vector2.ZERO
		if blackboard.has_var(sound_position_var):
			sound_pos = blackboard.get_var(sound_position_var)
		
		if sound_pos != Vector2.ZERO:
			# Check current state - if Passive, transition to Alert
			var current_state: String = "Passive"
			if blackboard.has_var(npc_state_var):
				current_state = blackboard.get_var(npc_state_var)
			
			# If in Passive state and gauge is full, transition to Alert
			if current_state == "Passive":
				return SUCCESS
			# If already in Alert, stay in Alert
			elif current_state == "Alert":
				return SUCCESS
	
	return FAILURE
