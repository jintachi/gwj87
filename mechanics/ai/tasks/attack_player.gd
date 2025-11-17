#*
#* attack_player.gd
#* =============================================================================
#* Alert Level 2: Combat behavior - attacks the player.
#* =============================================================================
#*
@tool
extends BTAction
## Attacks the player in combat mode. [br]
## Returns [code]RUNNING[/code] while in combat.

## Name of the SceneTree group containing the player.
@export var player_group: StringName = &"player"

## Blackboard variable for desired speed (float).
@export var speed_var: StringName = &"speed"

## Blackboard variable for last sight position (Vector2).
@export var last_sight_position_var: StringName = &"last_sight_position"

## Blackboard variable for sound position (Vector2).
@export var sound_position_var: StringName = &"sound_position"

## Blackboard variable for player visibility (bool).
@export var player_visible_var: StringName = &"player_visible"

## Blackboard variable for player audibility (bool).
@export var player_audible_var: StringName = &"player_audible"

## Maximum distance to maintain from target.
@export var stop_distance: float = 50.0

## Minimum distance before considering target reached.
@export var arrival_tolerance: float = 20.0


func _generate_name() -> String:
	return "Attack Player"


## Blackboard variable for alert level (int).
@export var alert_level_var: StringName = &"alert_level"

## Target alert level required for this task (should be 3 for engaged/chasing).
@export var required_alert_level: int = 3


func _enter() -> void:
	# Get alert level to verify it's correct when task is entered
	var alert_level: int = 0
	if blackboard.has_var(alert_level_var):
		alert_level = blackboard.get_var(alert_level_var)
	print("Attack Player: Task ENTERED - Starting combat pursuit (Alert Level 3, current alert_level=%d)" % alert_level)


func _tick(delta: float) -> Status:
	var debug_tick : int = int(Time.get_ticks_msec() / 2000)  # Every 2 seconds
	# Check alert level first - must be at required level to continue
	var alert_level: int = 0
	if blackboard.has_var(alert_level_var):
		alert_level = blackboard.get_var(alert_level_var)
	
	# Debug: ALWAYS print when alert level is 3 to verify task is running
	# Print EVERY frame when alert level is 3 (not just every 2 seconds)
	if alert_level == 3:
		# Print every frame for first 20 ticks, then every 2 seconds
		if not has_meta("alert3_tick_count"):
			set_meta("alert3_tick_count", 0)
		var alert3_tick_count: int = get_meta("alert3_tick_count")
		alert3_tick_count += 1
		set_meta("alert3_tick_count", alert3_tick_count)
		
		if alert3_tick_count <= 20 or debug_tick != get_meta("last_alert3_tick", -1):
			set_meta("last_alert3_tick", debug_tick)
			print("Attack Player: _tick() #%d - alert_level=%d (required %d) - TASK IS RUNNING" % [
				alert3_tick_count, alert_level, required_alert_level
			])
	
	# Debug: Verify task is running
	if not has_meta("tick_count"):
		set_meta("tick_count", 0)
		set_meta("last_alert_level", -1)
	var tick_count: int = get_meta("tick_count")
	var last_alert_level: int = get_meta("last_alert_level")
	tick_count += 1
	set_meta("tick_count", tick_count)
	
	# Check if alert level changed (task was re-entered or level changed)
	if alert_level != last_alert_level:
		set_meta("last_alert_level", alert_level)
		if alert_level == required_alert_level:
			print("Attack Player: Alert level changed to %d (required %d) - Task should run!" % [
				alert_level, required_alert_level
			])
		else:
			print("Attack Player: Alert level is %d (required %d), exiting combat" % [
				alert_level, required_alert_level
			])
	
	# Always print debug for first 10 ticks to verify task is being called
	if tick_count <= 10:
		print("Attack Player: _tick() #%d - alert_level=%d, required=%d" % [
			tick_count, alert_level, required_alert_level
		])
	elif tick_count % 60 == 0:  # Every 60 ticks after first 10
		print("Attack Player: _tick() #%d - alert_level=%d, required=%d" % [
			tick_count, alert_level, required_alert_level
		])
	
	# CRITICAL: Return SUCCESS immediately when alert level doesn't match
	# With BTParallel, all tasks run simultaneously, so we return SUCCESS to exit early
	# Only the matching alert level task will continue and set movement
	if alert_level != required_alert_level:
		# Alert level doesn't match, return SUCCESS immediately (task completes, doesn't interfere)
		# Don't set movement - the matching alert level task will handle movement
		if tick_count <= 20 or (alert_level == 3 and debug_tick != get_meta("last_success_tick", -1)):
			set_meta("last_success_tick", debug_tick)
			print("Attack Player: Alert level %d != required %d, returning SUCCESS (exiting, not setting movement) (tick #%d)" % [
				alert_level, required_alert_level, tick_count
			])
		# Return SUCCESS so task exits - matching alert level task will handle movement
		return SUCCESS
	
	# Alert level matches! Task should run
	if tick_count <= 20 or debug_tick != get_meta("last_success_tick", -1):
		set_meta("last_success_tick", debug_tick)
		print("Attack Player: Alert level matches! Starting pursuit (tick #%d)" % tick_count)

	var players: Array[Node] = agent.get_tree().get_nodes_in_group(player_group)

	if players.is_empty():
		print("Attack Player: No players found!")
		return FAILURE

	var player: Node2D = players[0] as Node2D
	if not is_instance_valid(player):
		print("Attack Player: Player is invalid!")
		return FAILURE

	# Get detection status
	var player_visible: bool = false
	if blackboard.has_var(player_visible_var):
		player_visible = blackboard.get_var(player_visible_var)

	var player_audible: bool = false
	if blackboard.has_var(player_audible_var):
		player_audible = blackboard.get_var(player_audible_var)

	# Debug: Print detection status every frame for first 10 ticks, then every 2 seconds
	debug_tick = int(Time.get_ticks_msec() / 2000)  # Every 2 seconds
	if tick_count <= 10 or debug_tick != get_meta("last_debug_tick", -1):
		set_meta("last_debug_tick", debug_tick)
		print("Attack Player: visible=%s, audible=%s, player_pos=%s, agent_pos=%s" % [
			player_visible, player_audible, player.global_position, agent.global_position
		])

	# Determine target position based on priority:
	# 1. If player is visible: pursue actual player position (highest priority)
	# 2. Else if player is audible: pursue sound position
	# 3. Else (both lost): move to last known location
	var target_pos: Vector2 = Vector2.ZERO
	var pursuing_live_target: bool = false

	if player_visible:
		# Priority 1: Player is visible - pursue actual position
		target_pos = player.global_position
		pursuing_live_target = true
		# Update last sight position
		blackboard.set_var(last_sight_position_var, target_pos)
		if tick_count <= 10 or debug_tick != get_meta("last_target_tick", -1):
			set_meta("last_target_tick", debug_tick)
			print("Attack Player: Player VISIBLE - targeting player position: %s" % target_pos)
	elif player_audible:
		# Priority 2: Player is audible - pursue sound position
		if blackboard.has_var(sound_position_var):
			var sound_pos: Vector2 = blackboard.get_var(sound_position_var)
			if sound_pos != Vector2.ZERO:
				target_pos = sound_pos
				pursuing_live_target = true
				if tick_count <= 10 or debug_tick != get_meta("last_target_tick", -1):
					set_meta("last_target_tick", debug_tick)
					print("Attack Player: Player AUDIBLE - targeting sound position: %s" % target_pos)
			else:
				if tick_count <= 10 or debug_tick != get_meta("last_target_tick", -1):
					set_meta("last_target_tick", debug_tick)
					print("Attack Player: Player audible but sound_position is ZERO, using player position")
				target_pos = player.global_position
				pursuing_live_target = true
	else:
		# Priority 3: Both lost - still pursue player's current position (they might be hiding)
		# This ensures we continue chasing even if detection temporarily fails
		target_pos = player.global_position
		pursuing_live_target = true  # Still pursuing a live target (player exists, just not detected)
		if tick_count <= 10 or debug_tick != get_meta("last_fallback_tick", -1):
			set_meta("last_fallback_tick", debug_tick)
			print("Attack Player: Both lost but still pursuing player at: %s (last_sight=%s, sound=%s)" % [
				target_pos,
				blackboard.get_var(last_sight_position_var) if blackboard.has_var(last_sight_position_var) else Vector2.ZERO,
				blackboard.get_var(sound_position_var) if blackboard.has_var(sound_position_var) else Vector2.ZERO
			])

	if target_pos == Vector2.ZERO:
		# No target available (shouldn't happen with fallback above)
		if debug_tick != get_meta("last_no_target_tick", -1):
			set_meta("last_no_target_tick", debug_tick)
			print("Attack Player: ERROR - No target available (visible=%s, audible=%s, player_pos=%s)" % [
				player_visible, player_audible, player.global_position
			])
		return RUNNING

	# Move towards target
	var to_target: Vector2 = target_pos - agent.global_position
	var distance: float = to_target.length()

	# Debug: Print pursuit info occasionally and for first few ticks
	if tick_count <= 5 or (debug_tick != get_meta("last_pursuit_tick", -1)):
		set_meta("last_pursuit_tick", debug_tick)
		print("Attack Player: Pursuing target at %s, distance=%.0f, live_target=%s, agent_pos=%s" % [
			target_pos, distance, pursuing_live_target, agent.global_position
		])

	# Get speed
	var speed: float = 300.0
	if blackboard.has_var(speed_var):
		speed = blackboard.get_var(speed_var)

	# Always face the target when pursuing
	var direction: Vector2 = to_target.normalized()
	if agent.has_method("face_dir"):
		agent.face_dir(direction)

	# Check if we've reached the target
	if distance <= arrival_tolerance:
		agent.move(Vector2.ZERO)
		if not pursuing_live_target:
			# Reached last known location, look around
			print("Attack Player: Reached last known location, searching...")
		return RUNNING

	# Pursue target - move towards them
	var desired_velocity: Vector2 = direction * speed

	# Always print movement command for first 20 ticks when alert level is 3
	if alert_level == 3:
		if not has_meta("movement_tick_count"):
			set_meta("movement_tick_count", 0)
		var movement_tick_count: int = get_meta("movement_tick_count")
		movement_tick_count += 1
		set_meta("movement_tick_count", movement_tick_count)
		
		if movement_tick_count <= 20 or debug_tick != get_meta("last_movement_tick", -1):
			set_meta("last_movement_tick", debug_tick)
			print("Attack Player: MOVING with velocity %s (speed=%.0f, direction=%s, target=%s, distance=%.0f)" % [
				desired_velocity, speed, direction, target_pos, distance
			])

	agent.move(desired_velocity)
	agent.update_facing()

	return RUNNING
