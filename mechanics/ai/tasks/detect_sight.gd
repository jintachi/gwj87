#*
#* detect_sight.gd
#* =============================================================================
#* Independent sight detection - checks if player is visible and contributes to alert level.
#* =============================================================================
#*
@tool
extends BTAction
## Checks if player is visible through sight. [br]
## Sets blackboard variables for sight detection status. [br]
## Returns [code]SUCCESS[/code] always (doesn't block sequence).

## Name of the SceneTree group containing the player.
@export var player_group: StringName = &"player"

## Maximum vision range.
@export var vision_range: float = 400.0

## Vision cone angle in degrees (half-angle from forward direction).
@export var vision_angle: float = 60.0

## Collision layers to check for obstacles (line of sight).
@export var obstacle_layers: int = 1

## Blackboard variable to store if player is visible (bool).
@export var player_visible_var: StringName = &"player_visible"

## Blackboard variable to store last sight time (float, seconds since last sight).
@export var last_sight_time_var: StringName = &"last_sight_time"

## Blackboard variable to store player position when last seen (Vector2).
@export var last_sight_position_var: StringName = &"last_sight_position"

## Blackboard variable to store sight detection timer (float, increases when visible).
@export var sight_detection_timer_var: StringName = &"sight_detection_timer"

## Blackboard variable to store time since player became invisible (float).
@export var not_visible_time_var: StringName = &"not_visible_time"

## Blackboard variable to store if NPC is currently detecting (bool).
@export var is_detecting_var: StringName = &"is_detecting"

## Blackboard variable to store alert level (int).
@export var alert_level_var: StringName = &"alert_level"


func _generate_name() -> String:
	return "Detect Sight  range: %.0f, angle: %.0f°" % [vision_range, vision_angle]


func _enter() -> void:
	# Initialize blackboard variables
	if not blackboard.has_var(player_visible_var):
		blackboard.set_var(player_visible_var, false)
	if not blackboard.has_var(last_sight_time_var):
		blackboard.set_var(last_sight_time_var, 0.0)
	if not blackboard.has_var(last_sight_position_var):
		blackboard.set_var(last_sight_position_var, Vector2.ZERO)
	if not blackboard.has_var(sight_detection_timer_var):
		blackboard.set_var(sight_detection_timer_var, 0.0)
	if not blackboard.has_var(not_visible_time_var):
		blackboard.set_var(not_visible_time_var, 0.0)
	if not blackboard.has_var(is_detecting_var):
		blackboard.set_var(is_detecting_var, false)
	print("Detect Sight: Task ENTERED - Initialized blackboard variables")


func _tick(delta: float) -> Status:
	# Check alert level - detection should always run, but we check to ensure it's valid
	# Detection runs at all alert levels (0-3), so we don't restrict it
	# This check is here for consistency with other tasks
	var alert_level: int = 0
	if blackboard.has_var(alert_level_var):
		alert_level = blackboard.get_var(alert_level_var)
	
	# Debug: Print every tick to verify task is running
	if not has_meta("tick_count"):
		set_meta("tick_count", 0)
	var tick_count: int = get_meta("tick_count")
	tick_count += 1
	set_meta("tick_count", tick_count)
	if tick_count % 60 == 0:  # Every 60 ticks (~1 second at 60fps)
		print("Detect Sight: _tick() called %d times (alert_level=%d)" % [tick_count, alert_level])
	
	var players: Array[Node] = agent.get_tree().get_nodes_in_group(player_group)
	
	var is_visible: bool = false
	var sight_position: Vector2 = Vector2.ZERO
	
	# Debug: Print occasionally
	var debug_tick: int = int(Time.get_ticks_msec() / 2000)  # Every 2 seconds
	if debug_tick != get_meta("last_debug_tick", -1):
		set_meta("last_debug_tick", debug_tick)
		print("Detect Sight: Found %d players in group '%s' (agent: %s at %s)" % [
			players.size(), player_group, agent.name, agent.global_position
		])
	
	if players.is_empty():
		blackboard.set_var(player_visible_var, false)
		_handle_not_visible(delta)
		return RUNNING
	
	var player: Node2D = players[0] as Node2D
	if not is_instance_valid(player):
		blackboard.set_var(player_visible_var, false)
		_handle_not_visible(delta)
		return RUNNING
	
	var to_player: Vector2 = player.global_position - agent.global_position
	var distance: float = to_player.length()
	
	# Debug: Print occasionally
	debug_tick = int(Time.get_ticks_msec() / 2000)  # Every 2 seconds
	if debug_tick != get_meta("last_debug_tick", -1):
		set_meta("last_debug_tick", debug_tick)
		print("Detect Sight: Player at distance %.0f (range: %.0f), visible=%s" % [
			distance, vision_range, blackboard.get_var(player_visible_var) if blackboard.has_var(player_visible_var) else "unknown"
		])
	
	# Check range
	if distance > vision_range:
		blackboard.set_var(player_visible_var, false)
		_handle_not_visible(delta)
		return RUNNING
	
	# Check vision cone
	var forward: Vector2
	if agent.has_method("get_facing_direction"):
		forward = agent.get_facing_direction()
		if forward.length() < 0.1:
			forward = Vector2.RIGHT
	else:
		var facing: float = 1.0
		if agent.has_method("get_facing"):
			facing = agent.get_facing()
		forward = Vector2.RIGHT * facing
	
	var to_player_normalized: Vector2 = to_player.normalized()
	var angle_to_player: float = rad_to_deg(forward.angle_to(to_player_normalized))
	
	# Debug: Print vision cone check
	debug_tick = int(Time.get_ticks_msec() / 2000)  # Every 2 seconds
	if debug_tick != get_meta("last_angle_tick", -1):
		set_meta("last_angle_tick", debug_tick)
		print("Detect Sight: angle_to_player=%.1f°, vision_angle=%.1f°, forward=%s" % [
			abs(angle_to_player), vision_angle, forward
		])
	
	if abs(angle_to_player) > vision_angle:
		blackboard.set_var(player_visible_var, false)
		_handle_not_visible(delta)
		return RUNNING
	
	# Check line of sight
	var space_state = agent.get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(
		agent.global_position,
		player.global_position
	)
	query.collision_mask = obstacle_layers
	query.exclude = [agent.get_rid()]
	if player is CharacterBody2D or player is RigidBody2D or player is Area2D:
		query.exclude.append(player.get_rid())
	
	var result = space_state.intersect_ray(query)
	
	if not result.is_empty():
		var collider = result.get("collider", null)
		# If we hit the player, line of sight is clear (shouldn't happen with exclude, but check anyway)
		if collider == player:
			# Line of sight is clear, continue to visibility check
			pass
		else:
			# Line of sight is blocked by something else
			# Debug: Print line of sight check
			debug_tick = int(Time.get_ticks_msec() / 2000)  # Every 2 seconds
			if debug_tick != get_meta("last_los_tick", -1):
				set_meta("last_los_tick", debug_tick)
				print("Detect Sight: Line of sight BLOCKED by %s" % (collider.name if collider else "unknown"))
			blackboard.set_var(player_visible_var, false)
			_handle_not_visible(delta)
			return RUNNING
	
	# Player is visible!
	is_visible = true
	sight_position = player.global_position
	
	# Check if we were previously not detecting (transition to detecting)
	var was_detecting: bool = false
	if blackboard.has_var(is_detecting_var):
		was_detecting = blackboard.get_var(is_detecting_var)
	
	blackboard.set_var(player_visible_var, true)
	blackboard.set_var(last_sight_time_var, 0.0)
	blackboard.set_var(last_sight_position_var, sight_position)
	blackboard.set_var(not_visible_time_var, 0.0)  # Reset not visible time
	blackboard.set_var(is_detecting_var, true)  # Start detecting
	
	# Get alert level
	if blackboard.has_var(alert_level_var):
		alert_level = blackboard.get_var(alert_level_var)
	
	# At alert level 0 (Passive), don't face or stop for player - just patrol
	# At alert level 1+ (Cautious/Investigating/Engaged), behavior tasks handle facing/movement
	if alert_level >= 1:
		# At alert level 1+, only face the player (don't stop movement - behavior tasks handle that)
		to_player_normalized = to_player.normalized()
		if agent.has_method("face_dir"):
			agent.face_dir(to_player_normalized)
	
	# Increment detection timer when player is visible AND detecting
	# Only increment if timer hasn't been reset this frame (check if it's 0.0, which might indicate a reset)
	var detection_timer: float = 0.0
	if blackboard.has_var(sight_detection_timer_var):
		detection_timer = blackboard.get_var(sight_detection_timer_var)
	
	# Increment timer (manage_alert_level will reset it if it exceeds 10 seconds)
	detection_timer += delta
	blackboard.set_var(sight_detection_timer_var, detection_timer)
	
	# Debug: Print when player becomes visible or starts detecting
	if not was_detecting:
		print("Detect Sight: Started DETECTING player at distance %.0f!" % distance)
	
	debug_tick = int(Time.get_ticks_msec() / 1000)  # Every 1 second
	if debug_tick != get_meta("last_visible_tick", -1):
		set_meta("last_visible_tick", debug_tick)
		print("Detect Sight: Player VISIBLE at distance %.0f! Detection timer: %.2f" % [distance, detection_timer])
	
	# Return RUNNING to keep detection active continuously
	return RUNNING


func _handle_not_visible(delta: float) -> void:
	# Increment time since last sight
	var last_sight_time: float = 0.0
	if blackboard.has_var(last_sight_time_var):
		last_sight_time = blackboard.get_var(last_sight_time_var)
	blackboard.set_var(last_sight_time_var, last_sight_time + delta)
	
	# Check if we were previously detecting (transition to not detecting)
	var was_detecting: bool = false
	if blackboard.has_var(is_detecting_var):
		was_detecting = blackboard.get_var(is_detecting_var)
	
	# Track time since player became invisible
	var not_visible_time: float = 0.0
	if blackboard.has_var(not_visible_time_var):
		not_visible_time = blackboard.get_var(not_visible_time_var)
	not_visible_time += delta
	blackboard.set_var(not_visible_time_var, not_visible_time)
	
	# If we were detecting, pause detection timer (but keep is_detecting true for 2 seconds)
	if was_detecting:
		# Debug: Print when detection pauses
		var debug_tick: int = int(Time.get_ticks_msec() / 1000)  # Every 1 second
		if debug_tick != get_meta("last_pause_tick", -1):
			set_meta("last_pause_tick", debug_tick)
			var detection_timer: float = 0.0
			if blackboard.has_var(sight_detection_timer_var):
				detection_timer = blackboard.get_var(sight_detection_timer_var)
			print("Detect Sight: PAUSED detecting. Timer: %.2f, Not visible for: %.2fs" % [detection_timer, not_visible_time])
	
	# After 2 seconds of not seeing player, resume patrol and decrease timer at 2x speed
	var detection_timer: float = 0.0
	if blackboard.has_var(sight_detection_timer_var):
		detection_timer = blackboard.get_var(sight_detection_timer_var)
	
	if not_visible_time >= 2.0:
		# Resume patrol by setting is_detecting to false (allows patrol to move)
		if was_detecting:
			blackboard.set_var(is_detecting_var, false)
			print("Detect Sight: Resuming patrol after 2 seconds of not seeing player")
		
		# Decrease detection timer at 2x speed (2 seconds per second)
		if detection_timer > 0.0:
			detection_timer = max(0.0, detection_timer - (delta * 2.0))
			blackboard.set_var(sight_detection_timer_var, detection_timer)
			
			# Debug: Print when timer decreases
			var debug_tick: int = int(Time.get_ticks_msec() / 2000)  # Every 2 seconds
			if debug_tick != get_meta("last_decay_tick", -1):
				set_meta("last_decay_tick", debug_tick)
				print("Detect Sight: Timer decreasing at 2x speed. Timer: %.2f, Not visible for: %.2fs" % [detection_timer, not_visible_time])
