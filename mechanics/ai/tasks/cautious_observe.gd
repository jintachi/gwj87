#*
#* cautious_observe.gd
#* =============================================================================
#* Alert Level 1: Cautious - Stands still and faces the player when detected.
#* =============================================================================
#*
@tool
extends BTAction
## Cautious behavior - stops and faces player when sight or sound reach threshold. [br]
## Returns [code]RUNNING[/code] while in cautious state.

## Blackboard variable for alert level (int).
@export var alert_level_var: StringName = &"alert_level"

## Target alert level required for this task (should be 1 for cautious).
@export var required_alert_level: int = 1

## Blackboard variable for player visibility (bool).
@export var player_visible_var: StringName = &"player_visible"

## Blackboard variable for player audibility (bool).
@export var player_audible_var: StringName = &"player_audible"

## Blackboard variable for sound position (Vector2).
@export var sound_position_var: StringName = &"sound_position"

## Name of the SceneTree group containing the player.
@export var player_group: StringName = &"player"


func _generate_name() -> String:
	return "Cautious Observe"


func _enter() -> void:
	print("Cautious Observe: Task ENTERED - Standing still and observing")


func _tick(_delta: float) -> Status:
	# Check alert level first - must be at required level to continue
	var alert_level: int = 0
	if blackboard.has_var(alert_level_var):
		alert_level = blackboard.get_var(alert_level_var)
	
	# Debug: Print when running to verify task is active
	var debug_tick: int = int(float(Time.get_ticks_msec()) / 2000.0)  # Every 2 seconds
	if debug_tick != get_meta("last_debug_tick", -1):
		set_meta("last_debug_tick", debug_tick)
		print("Cautious Observe: _tick() - alert_level=%d, required=%d" % [alert_level, required_alert_level])
	
	if alert_level != required_alert_level:
		# Alert level changed, return SUCCESS immediately (task completes, doesn't interfere)
		# Don't set movement - the matching alert level task (patrol) will handle movement
		if debug_tick != get_meta("last_success_tick", -1):
			set_meta("last_success_tick", debug_tick)
			print("Cautious Observe: Alert level %d != required %d, returning SUCCESS (exiting, not setting movement)" % [
				alert_level, required_alert_level
			])
		# Return SUCCESS so task exits - matching alert level task will handle movement
		return SUCCESS
	
	# Stop movement - stand still
	# At Alert Level 1, NPC does NOT rotate to face player (that happens at Alert Level 2+)
	if agent.has_method("move"):
		agent.move(Vector2.ZERO)
	
	return RUNNING

