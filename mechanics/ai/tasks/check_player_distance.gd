#*
#* check_player_distance.gd
#* =============================================================================
#* Condition task to check player distance with different thresholds.
#* =============================================================================
#*
@tool
extends BTAction
## Checks player distance against thresholds. [br]
## Returns [code]SUCCESS[/code] if player is > far_threshold (needs to move closer). [br]
## Returns [code]SUCCESS[/code] if player is < near_threshold (ready to attack). [br]
## Returns [code]FAILURE[/code] otherwise.

## Name of the SceneTree group containing the player.
@export var player_group: StringName = &"player"

## Distance threshold for "too far" check (> this = needs to move closer).
@export var far_threshold: float = 320.0

## Distance threshold for "close enough" check (< this = ready to attack).
@export var near_threshold: float = 325.0

## Check mode: 0 = check if > far_threshold, 1 = check if < near_threshold
@export var check_mode: int = 0  # 0 = too far, 1 = close enough


func _generate_name() -> String:
	if check_mode == 0:
		return "Check Player Distance > %.0fpx" % far_threshold
	else:
		return "Check Player Distance < %.0fpx" % near_threshold


func _enter() -> void:
	pass


func _tick(_delta: float) -> Status:
	# Calculate distance to player
	var player_pos: Vector2 = Player.instance.global_position
	var agent_pos: Vector2 = agent.global_position
	var distance: float = agent_pos.distance_to(player_pos)
	
	# Check based on mode
	if check_mode == 0:
		# Check if too far (> far_threshold)
		if distance > far_threshold:
			return SUCCESS
		else:
			return FAILURE
	else:
		# Check if close enough (< near_threshold)
		if distance < near_threshold:
			return SUCCESS
		else:
			return FAILURE
