#*
#* look_toward_sound.gd
#* =============================================================================
#* Alert Level 1: Caution - Faces the direction of a sound from the player.
#* =============================================================================
#*
@tool
extends BTAction
## Faces the direction of sound when player is audible. [br]
## Returns [code]RUNNING[/code] while in caution state. [br]
## Returns [code]SUCCESS[/code] if alert level != 1 (exits early).

## Blackboard variable for alert level (int).
@export var alert_level_var: StringName = &"alert_level"

## Blackboard variable for player audibility (bool).
@export var player_audible_var: StringName = &"player_audible"

## Blackboard variable for sound position (Vector2).
@export var sound_position_var: StringName = &"sound_position"

## Target alert level required for this task (should be 1 for caution).
@export var required_alert_level: int = 1


func _generate_name() -> String:
	return "Look Toward Sound"


func _enter() -> void:
	pass


func _tick(_delta: float) -> Status:
	# Check alert level first - must be at required level to continue
	var alert_level: int = 0
	if blackboard.has_var(alert_level_var):
		alert_level = blackboard.get_var(alert_level_var)
	
	if alert_level != required_alert_level:
		# Alert level changed, return SUCCESS immediately
		return SUCCESS
	
	# Check if player is audible
	var player_audible: bool = false
	if blackboard.has_var(player_audible_var):
		player_audible = blackboard.get_var(player_audible_var)
	
	if player_audible:
		# Get sound position
		var sound_position: Vector2 = Vector2.ZERO
		if blackboard.has_var(sound_position_var):
			sound_position = blackboard.get_var(sound_position_var)
		
		if sound_position != Vector2.ZERO:
			# Face direction of sound
			var to_sound: Vector2 = sound_position - agent.global_position
			var direction: Vector2 = to_sound.normalized()
			if agent.has_method("face_dir"):
				agent.face_dir(direction)
	
	return RUNNING

