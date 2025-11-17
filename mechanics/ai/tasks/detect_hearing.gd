#*
#* detect_hearing.gd
#* =============================================================================
#* Independent hearing detection - checks if player is audible and contributes to alert level.
#* =============================================================================
#*
@tool
extends BTAction
## Checks if player is audible through sound. [br]
## Sets blackboard variables for hearing detection status. [br]
## Returns [code]SUCCESS[/code] always (doesn't block sequence).

## Name of the SceneTree group containing the player.
@export var player_group: StringName = &"player"

## Maximum hearing range.
@export var hearing_range: float = 300.0

## Blackboard variable to store if player is audible (bool).
@export var player_audible_var: StringName = &"player_audible"

## Blackboard variable to store last hearing time (float, seconds since last sound).
@export var last_hearing_time_var: StringName = &"last_hearing_time"

## Blackboard variable to store sound position (Vector2).
@export var sound_position_var: StringName = &"sound_position"

## Blackboard variable to store hearing detection gauge (float, 0.0-1.0, increases when audible).
@export var hearing_gauge_var: StringName = &"hearing_gauge"

## Blackboard variable to store time since player became inaudible (float).
@export var not_audible_time_var: StringName = &"not_audible_time"

## Blackboard variable for alert level (int) - detection runs at all alert levels.
@export var alert_level_var: StringName = &"alert_level"


func _generate_name() -> String:
	return "Detect Hearing  range: %.0f" % hearing_range


func _enter() -> void:
	# Initialize blackboard variables
	if not blackboard.has_var(player_audible_var):
		blackboard.set_var(player_audible_var, false)
	if not blackboard.has_var(last_hearing_time_var):
		blackboard.set_var(last_hearing_time_var, 0.0)
	if not blackboard.has_var(sound_position_var):
		blackboard.set_var(sound_position_var, Vector2.ZERO)
	if not blackboard.has_var(hearing_gauge_var):
		blackboard.set_var(hearing_gauge_var, 0.0)
	if not blackboard.has_var(not_audible_time_var):
		blackboard.set_var(not_audible_time_var, 0.0)
	print("Detect Hearing: Task ENTERED - Initialized blackboard variables")


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
		print("Detect Hearing: _tick() called %d times (alert_level=%d)" % [tick_count, alert_level])
	
	var players: Array[Node] = agent.get_tree().get_nodes_in_group(player_group)
	
	var is_audible: bool = false
	var sound_pos: Vector2 = Vector2.ZERO
	
	# Debug: Print occasionally
	var debug_tick: int = int(float(Time.get_ticks_msec()) / 2000.0)  # Every 2 seconds
	if debug_tick != get_meta("last_debug_tick", -1):
		set_meta("last_debug_tick", debug_tick)
		print("Detect Hearing: Found %d players in group '%s' (agent: %s at %s)" % [
			players.size(), player_group, agent.name, agent.global_position
		])
	
	if players.is_empty():
		blackboard.set_var(player_audible_var, false)
		_handle_not_audible(delta)
		return RUNNING

	var player: Node2D = players[0] as Node2D
	if not is_instance_valid(player):
		blackboard.set_var(player_audible_var, false)
		_handle_not_audible(delta)
		return RUNNING

	var to_player: Vector2 = player.global_position - agent.global_position
	var distance: float = to_player.length()

	# Debug: Print occasionally
	debug_tick = int(float(Time.get_ticks_msec()) / 2000.0)  # Every 2 seconds
	if debug_tick != get_meta("last_debug_tick", -1):
		set_meta("last_debug_tick", debug_tick)
		print("Detect Hearing: Player at distance %.0f (range: %.0f)" % [distance, hearing_range])

	# Check range
	if distance > hearing_range:
		blackboard.set_var(player_audible_var, false)
		_handle_not_audible(delta)
		return RUNNING
	
	# Check if player is making noise
	var noise_level: float = 0.0
	if player.has_method("get_noise_level"):
		noise_level = player.get_noise_level()
	
	# Check sound events
	var has_sound_events: bool = false
	if player.has_method("get_sound_events"):
		var sound_events: Array = player.get_sound_events()
		has_sound_events = not sound_events.is_empty()
		if has_sound_events:
			# Use position of most recent sound event
			var latest_event = sound_events[-1]
			if latest_event is Dictionary and latest_event.has("position"):
				sound_pos = latest_event.position
	
	if noise_level > 0.0 or has_sound_events:
		is_audible = true
		if sound_pos == Vector2.ZERO:
			sound_pos = player.global_position
	
	blackboard.set_var(player_audible_var, is_audible)
	
	# Debug: Print noise level (after is_audible is set)
	if debug_tick != get_meta("last_noise_tick", -1):
		set_meta("last_noise_tick", debug_tick)
		print("Detect Hearing: noise_level=%.2f, has_sound_events=%s, audible=%s" % [
			noise_level, has_sound_events, is_audible
		])

	if is_audible:
		blackboard.set_var(last_hearing_time_var, 0.0)
		blackboard.set_var(sound_position_var, sound_pos)
		blackboard.set_var(not_audible_time_var, 0.0)  # Reset not audible time

		# Increment hearing gauge when player is audible (reduced by 70% - multiply by 0.3)
		var hearing_gauge: float = 0.0
		if blackboard.has_var(hearing_gauge_var):
			hearing_gauge = blackboard.get_var(hearing_gauge_var)
		hearing_gauge += delta * 0.3  # 70% reduction (30% of original speed)
		hearing_gauge = min(1.0, hearing_gauge)  # Cap at 100%
		blackboard.set_var(hearing_gauge_var, hearing_gauge)

		# Debug: Print when player becomes audible
		if debug_tick != get_meta("last_audible_tick", -1):
			set_meta("last_audible_tick", debug_tick)
			print("Detect Hearing: Player AUDIBLE at distance %.0f! Hearing gauge: %.1f%%" % [
				distance, hearing_gauge * 100.0
			])
	else:
		# Handle not audible (pause gauge, track time, decrease after 2 seconds)
		_handle_not_audible(delta)

	# Return RUNNING to keep detection active continuously
	return RUNNING


func _handle_not_audible(delta: float) -> void:
	# Increment time since last hearing
	var last_hearing_time: float = 0.0
	if blackboard.has_var(last_hearing_time_var):
		last_hearing_time = blackboard.get_var(last_hearing_time_var)
	blackboard.set_var(last_hearing_time_var, last_hearing_time + delta)

	# Track time since player became inaudible
	var not_audible_time: float = 0.0
	if blackboard.has_var(not_audible_time_var):
		not_audible_time = blackboard.get_var(not_audible_time_var)
	not_audible_time += delta
	blackboard.set_var(not_audible_time_var, not_audible_time)

	# After 2 seconds of not hearing player, decrease gauge at 2x speed
	var hearing_gauge: float = 0.0
	if blackboard.has_var(hearing_gauge_var):
		hearing_gauge = blackboard.get_var(hearing_gauge_var)

	if not_audible_time >= 2.0:
		# Decrease hearing gauge at 2x speed (2 seconds per second)
		if hearing_gauge > 0.0:
			hearing_gauge = max(0.0, hearing_gauge - (delta * 2.0))
			blackboard.set_var(hearing_gauge_var, hearing_gauge)

			# Debug: Print when gauge decreases
			var debug_tick: int = int(float(Time.get_ticks_msec()) / 2000.0)  # Every 2 seconds
			if debug_tick != get_meta("last_decay_tick", -1):
				set_meta("last_decay_tick", debug_tick)
				print("Detect Hearing: Gauge decreasing at 2x speed. Gauge: %.1f%%, Not audible for: %.2fs" % [
					hearing_gauge * 100.0, not_audible_time
				])
