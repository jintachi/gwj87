#*
#* investigate.gd
#* =============================================================================
#* Alert Level 2: Investigates by moving to random positions near current location.
#* Uses pathfinding to avoid walls and obstacles.
#* =============================================================================
#*
@tool
extends BTAction
## Investigates by moving to random positions near current location. [br]
## Returns [code]RUNNING[/code] while investigating. [br]
## Returns [code]SUCCESS[/code] when investigation point is reached (cooldown handled by behavior tree).

## Blackboard variable for desired speed (float).
@export var speed_var: StringName = &"speed"

## Blackboard variable for investigation target position (Vector2).
@export var investigation_target_var: StringName = &"investigation_target"

## Blackboard variable for player visibility (bool).
@export var player_visible_var: StringName = &"player_visible"

## Radius around current location to search for investigation point.
@export var investigation_radius: float = 150.0

## How close to get to the investigation point.
@export var arrival_tolerance: float = 30.0

## Number of attempts to find a pathable position.
@export var max_attempts: int = 10

## Blackboard variable for alert level (int).
@export var alert_level_var: StringName = &"alert_level"

## Target alert level required for this task (should be 2 for investigation).
@export var required_alert_level: int = 2

## Blackboard variable for investigation cooldown timer (float).
@export var investigation_cooldown_var: StringName = &"investigation_cooldown"

## Blackboard variable for player audibility (bool).
@export var player_audible_var: StringName = &"player_audible"

## Blackboard variable for sound position (Vector2).
@export var sound_position_var: StringName = &"sound_position"

## Blackboard variable for last sight position (Vector2).
@export var last_sight_position_var: StringName = &"last_sight_position"

var _target_position: Vector2 = Vector2.ZERO
var _has_target: bool = false
var _previous_visible: bool = false
var _previous_audible: bool = false


func _generate_name() -> String:
	return "Investigate  radius: %.0f" % investigation_radius


func _enter() -> void:
	_has_target = false
	_target_position = Vector2.ZERO
	_previous_visible = false
	_previous_audible = false
	# Stop movement when entering investigation
	if agent.has_method("move"):
		agent.move(Vector2.ZERO)
	# Get alert level to verify it's correct when task is entered
	var alert_level: int = 0
	if blackboard.has_var(alert_level_var):
		alert_level = blackboard.get_var(alert_level_var)
	print("Investigate: Task ENTERED - Starting investigation (Alert Level 2, current alert_level=%d)" % alert_level)


func _tick(delta: float) -> Status:
	# Check alert level first - must be at required level to continue
	var alert_level: int = 0
	if blackboard.has_var(alert_level_var):
		alert_level = blackboard.get_var(alert_level_var)

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
			print("Investigate: Alert level changed to %d (required %d) - Task should run!" % [
				alert_level, required_alert_level
			])
		else:
			print("Investigate: Alert level is %d (required %d), exiting investigation" % [
				alert_level, required_alert_level
			])
	
	# Always print debug for first 20 ticks when alert level is 2
	if alert_level == 2:
		if tick_count <= 20:
			print("Investigate: _tick() #%d, alert_level=%d, required=%d - TASK IS RUNNING" % [
				tick_count, alert_level, required_alert_level
			])
		elif tick_count % 60 == 0:  # Every 60 ticks after first 20
			print("Investigate: _tick() #%d, alert_level=%d, required=%d" % [
				tick_count, alert_level, required_alert_level
			])
	elif tick_count <= 10:  # Print first 10 ticks even if alert level doesn't match
		print("Investigate: _tick() #%d, alert_level=%d, required=%d" % [
			tick_count, alert_level, required_alert_level
		])

	# CRITICAL: Return SUCCESS immediately when alert level doesn't match
	# With BTParallel, all tasks run simultaneously, so we return SUCCESS to exit early
	# Only the matching alert level task will continue and set movement
	if alert_level != required_alert_level:
		# Alert level doesn't match, return SUCCESS immediately (task completes, doesn't interfere)
		# Don't set movement - the matching alert level task will handle movement
		var debug_tick: int = int(float(Time.get_ticks_msec()) / 2000.0)  # Every 2 seconds
		if tick_count <= 20 or (alert_level == 2 and debug_tick != get_meta("last_success_tick", -1)):
			set_meta("last_success_tick", debug_tick)
			print("Investigate: Alert level %d != required %d, returning SUCCESS (exiting, not setting movement) (tick #%d)" % [
				alert_level, required_alert_level, tick_count
			])
		# Return SUCCESS so task exits - matching alert level task will handle movement
		return SUCCESS
	
	# Alert level matches! Task should run
	if tick_count <= 20 or tick_count % 60 == 0:
		print("Investigate: Alert level matches! Starting investigation (tick #%d)" % tick_count)

	# Check if player is currently visible
	var player_visible: bool = false
	if blackboard.has_var(player_visible_var):
		player_visible = blackboard.get_var(player_visible_var)

	# Check if player is currently audible
	var player_audible: bool = false
	if blackboard.has_var(player_audible_var):
		player_audible = blackboard.get_var(player_audible_var)

	# Check cooldown - decrement it if active
	var cooldown: float = 0.0
	if blackboard.has_var(investigation_cooldown_var):
		cooldown = blackboard.get_var(investigation_cooldown_var)
	
	# Decrement cooldown
	if cooldown > 0.0:
		cooldown = max(0.0, cooldown - delta)
		blackboard.set_var(investigation_cooldown_var, cooldown)
	
	# Check if player was newly detected (audible changed from false to true OR visible changed from false to true)
	# Note: If player becomes visible, we'll return FAILURE to escalate to Alert Level 3
	var new_sound_detection: bool = false
	var new_sight_detection: bool = false
	
	if player_audible and not _previous_audible:
		new_sound_detection = true
		if tick_count <= 5 or tick_count % 60 == 0:
			print("Investigate: New sound detection! audible=%s->%s" % [
				_previous_audible, player_audible
			])
	
	if player_visible and not _previous_visible:
		new_sight_detection = true
		if tick_count <= 5 or tick_count % 60 == 0:
			print("Investigate: New sight detection! visible=%s->%s" % [
				_previous_visible, player_visible
			])
	
	# Update previous states for next frame
	_previous_visible = player_visible
	_previous_audible = player_audible

	# Only investigate if player is not currently visible
	# (If they were recently seen, we'll use last_sight_position; otherwise use sound_position)
	if player_visible:
		# Player is currently visible, don't investigate (pursue/attack instead)
		if tick_count <= 5:
			print("Investigate: Player is visible, returning FAILURE (should escalate to level 3)")
		return FAILURE
	
	# Check if we need to update the target
	var should_update_target: bool = false
	var update_reason: String = ""
	
	# If we don't have a target yet, find an initial target
	if not _has_target:
		should_update_target = true
		update_reason = "no initial target"
	# If new detection occurred (new sound OR new sight), update target immediately
	elif new_sound_detection or new_sight_detection:
		should_update_target = true
		if new_sound_detection:
			update_reason = "new sound detection"
		else:
			update_reason = "new sight detection"
	# If cooldown expired and we've reached the current target, find a new target
	elif cooldown <= 0.0:
		var distance_to_target: float = agent.global_position.distance_to(_target_position)
		if distance_to_target <= arrival_tolerance:
			should_update_target = true
			update_reason = "cooldown expired and reached target"
	
	# Only update target if conditions are met
	if should_update_target:
		# Determine investigation position based on detection
		var investigation_pos: Vector2 = agent.global_position
		
		if new_sound_detection and player_audible and blackboard.has_var(sound_position_var):
			var sound_pos: Vector2 = blackboard.get_var(sound_position_var)
			if sound_pos != Vector2.ZERO:
				investigation_pos = sound_pos
		elif new_sight_detection and blackboard.has_var(last_sight_position_var):
			var last_sight_pos: Vector2 = blackboard.get_var(last_sight_position_var)
			if last_sight_pos != Vector2.ZERO:
				investigation_pos = last_sight_pos
		elif player_audible and blackboard.has_var(sound_position_var):
			var sound_pos: Vector2 = blackboard.get_var(sound_position_var)
			if sound_pos != Vector2.ZERO:
				investigation_pos = sound_pos
		elif blackboard.has_var(last_sight_position_var):
			var last_sight_pos: Vector2 = blackboard.get_var(last_sight_position_var)
			if last_sight_pos != Vector2.ZERO:
				investigation_pos = last_sight_pos
		
		# Find a random position within radius from investigation position
		_target_position = _find_pathable_position(investigation_pos)
		if _target_position == Vector2.ZERO:
			# Couldn't find a pathable position, use a position near investigation position
			var angle: float = randf() * TAU
			var random_distance: float = randf() * investigation_radius
			_target_position = investigation_pos + Vector2(cos(angle), sin(angle)) * random_distance
		
		_has_target = true
		blackboard.set_var(investigation_target_var, _target_position)
		# Set 2-second cooldown before next investigation point can be set
		blackboard.set_var(investigation_cooldown_var, 2.0)
		print("Investigate: Set new target to %s (from %s, reason: %s)" % [_target_position, investigation_pos, update_reason])
	
	# Move towards investigation target
	var distance_to_target: float = agent.global_position.distance_to(_target_position)
	
	if tick_count <= 5 or tick_count % 60 == 0:
		print("Investigate: Moving to %s, distance=%.0f" % [_target_position, distance_to_target])
	
	if distance_to_target <= arrival_tolerance:
		# Reached investigation point - wait for cooldown to expire before getting new position
		agent.move(Vector2.ZERO)
		if tick_count <= 5 or tick_count % 60 == 0:
			print("Investigate: Reached investigation point, waiting for cooldown (cooldown: %.1f)" % cooldown)
		return RUNNING  # Keep running, will get new position when cooldown expires
	
	# Use simple pathfinding: try to move directly, but check for obstacles
	var direction: Vector2 = agent.global_position.direction_to(_target_position)
	var speed: float = 200.0
	if blackboard.has_var(speed_var):
		speed = blackboard.get_var(speed_var)
	
	# Simple obstacle avoidance: check if direct path is blocked
	var space_state = agent.get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(
		agent.global_position,
		_target_position
	)
	query.collision_mask = 1  # Obstacle layer
	query.exclude = [agent.get_rid()]
	
	var result = space_state.intersect_ray(query)
	
	if result.is_empty():
		# Direct path is clear
		var desired_velocity: Vector2 = direction * speed
		agent.move(desired_velocity)
		agent.update_facing()
		if tick_count <= 5:
			print("Investigate: Moving with velocity %s (speed=%.0f)" % [desired_velocity, speed])
	else:
		# Path is blocked, try to path around
		# Simple approach: move perpendicular to obstacle
		var normal: Vector2 = result.get("normal", Vector2.UP)
		var perpendicular: Vector2 = Vector2(-normal.y, normal.x)
		var desired_velocity: Vector2 = perpendicular * speed * 0.5  # Move slower when avoiding
		agent.move(desired_velocity)
		agent.update_facing()
		if tick_count <= 5:
			print("Investigate: Path blocked, avoiding with velocity %s" % desired_velocity)
	
	return RUNNING


func _find_pathable_position(near_position: Vector2) -> Vector2:
	# Try to find a pathable position within radius
	for i in range(max_attempts):
		var angle: float = randf() * TAU
		var random_distance: float = randf() * investigation_radius
		var candidate: Vector2 = near_position + Vector2(cos(angle), sin(angle)) * random_distance
		
		# Check if position is walkable (not blocked by obstacles)
		if _is_pathable(candidate):
			return candidate
	
	# If no pathable position found, return zero (will use target position directly)
	return Vector2.ZERO


func _is_pathable(position: Vector2) -> bool:
	var space_state = agent.get_world_2d().direct_space_state
	var params := PhysicsPointQueryParameters2D.new()
	params.position = position
	params.collision_mask = 1  # Obstacle layer
	var collision = space_state.intersect_point(params)
	return collision.is_empty()

