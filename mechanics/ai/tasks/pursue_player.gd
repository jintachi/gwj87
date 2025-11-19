#*
#* pursue_player.gd
#* =============================================================================
#* Alert Level 3: Engaged - Pursues the player while unable to attack.
#* =============================================================================
#*
@tool
extends BTAction
## Pursues player while unable to attack. [br]
## Uses player position if visible/audible, otherwise uses last_known_player_location. [br]
## Normal speed (no multiplier). [br]
## Returns [code]RUNNING[/code] while pursuing. [br]
## Returns [code]SUCCESS[/code] if alert level != 3 (exits early).

## Blackboard variable for alert level (int).
@export var alert_level_var: StringName = &"alert_level"

## Blackboard variable for desired speed (float).
@export var speed_var: StringName = &"speed"

## Blackboard variable for player visibility (bool).
@export var player_visible_var: StringName = &"player_visible"

## Blackboard variable for player audibility (bool).
@export var player_audible_var: StringName = &"player_audible"

## Blackboard variable for last sight position (Vector2).
@export var last_sight_position_var: StringName = &"last_sight_position"

## Blackboard variable for sound position (Vector2).
@export var sound_position_var: StringName = &"sound_position"

## Blackboard variable for last known player location (Vector2).
@export var last_known_player_location_var: StringName = &"last_known_player_location"

## Name of the SceneTree group containing the player.
@export var player_group: StringName = &"player"

## Target alert level required for this task (should be 3 for engaged).
@export var required_alert_level: int = 3

## How close to get to the target.
@export var arrival_tolerance: float = 20.0


func _generate_name() -> String:
	return "Pursue Player"


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
	
	# Get detection status
	var player_visible: bool = false
	if blackboard.has_var(player_visible_var):
		player_visible = blackboard.get_var(player_visible_var)
	
	var player_audible: bool = false
	if blackboard.has_var(player_audible_var):
		player_audible = blackboard.get_var(player_audible_var)
	
	# Determine target position based on priority:
	# 1. If player is visible: pursue actual player position (highest priority)
	# 2. Else if player is audible: pursue sound position
	# 3. Else: use last known player location
	var target_pos: Vector2 = Vector2.ZERO
	
	if player_visible:
		# Priority 1: Player is visible - pursue actual position
		var players: Array[Node] = agent.get_tree().get_nodes_in_group(player_group)
		if not players.is_empty():
			var player: Node2D = players[0] as Node2D
			if is_instance_valid(player):
				target_pos = player.global_position
				# Update last sight position
				blackboard.set_var(last_sight_position_var, target_pos)
	elif player_audible:
		# Priority 2: Player is audible - pursue sound position
		if blackboard.has_var(sound_position_var):
			var sound_pos: Vector2 = blackboard.get_var(sound_position_var)
			if sound_pos != Vector2.ZERO:
				target_pos = sound_pos
	else:
		# Priority 3: Both lost - use last known location
		if blackboard.has_var(last_known_player_location_var):
			target_pos = blackboard.get_var(last_known_player_location_var)
		
		# Fallback to last sight position
		if target_pos == Vector2.ZERO:
			if blackboard.has_var(last_sight_position_var):
				target_pos = blackboard.get_var(last_sight_position_var)
	
	if target_pos == Vector2.ZERO:
		# No target available, stop
		agent.move(Vector2.ZERO)
		return RUNNING
	
	# Move toward target
	var to_target: Vector2 = target_pos - agent.global_position
	var distance: float = to_target.length()
	
	# Check if we've reached the target
	if distance <= arrival_tolerance:
		agent.move(Vector2.ZERO)
		return RUNNING
	
	# Get speed (no multiplier for engaged mode)
	var speed: float = 200.0
	if blackboard.has_var(speed_var):
		speed = blackboard.get_var(speed_var)
	
	# Pursue target - move towards them
	var direction: Vector2 = to_target.normalized()
	var desired_velocity: Vector2 = direction * speed
	
	agent.move(desired_velocity)
	agent.update_facing()
	
	return RUNNING
