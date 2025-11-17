#*
#* manage_alert_level.gd
#* =============================================================================
#* Manages alert level (0-3) based on sight and hearing detection.
#* 0 = Passive, 1 = Cautious, 2 = Investigating, 3 = Engaged/Chasing
#* =============================================================================
#*
@tool
extends BTAction
## Manages the alert level system. [br]
## Returns [code]SUCCESS[/code] always (doesn't block sequence).

## Blackboard variable that stores the alert level (int: 0-3).
@export var alert_level_var: StringName = &"alert_level"

## Blackboard variable for player visibility (bool).
@export var player_visible_var: StringName = &"player_visible"

## Blackboard variable for player audibility (bool).
@export var player_audible_var: StringName = &"player_audible"

## Blackboard variable for time since last sight (float).
@export var last_sight_time_var: StringName = &"last_sight_time"

## Blackboard variable for time since last hearing (float).
@export var last_hearing_time_var: StringName = &"last_hearing_time"

## Time in seconds without seeing or hearing player to drop from level 3 to 2.
@export var engaged_lose_time: float = 10.0

## Time in seconds without seeing or hearing player to drop from level 2 to 1.
@export var investigate_lose_time: float = 8.0

## Time in seconds without seeing or hearing player to drop from level 1 to 0.
@export var cautious_lose_time: float = 5.0

## Time in seconds of sustained detection before going from level 1 to 2 (cautious to investigating).
@export var detection_time_to_investigate: float = 2.0

## Time in seconds of sustained detection before going from level 2 to 3 (investigating to engaged).
@export var detection_time_to_engage: float = 2.0

## Blackboard variable for detection timer (float).
@export var detection_timer_var: StringName = &"detection_timer"

## Blackboard variable for sight detection timer (float).
@export var sight_detection_timer_var: StringName = &"sight_detection_timer"

## Blackboard variable for is_detecting (bool).
@export var is_detecting_var: StringName = &"is_detecting"

## Blackboard variable for hearing gauge (float, 0.0-1.0).
@export var hearing_gauge_var: StringName = &"hearing_gauge"

## Blackboard variable for alert level increase cooldown timer (float).
@export var alert_level_cooldown_var: StringName = &"alert_level_cooldown"

## Blackboard variable for alert level decay timer (float).
@export var alert_level_decay_timer_var: StringName = &"alert_level_decay_timer"

## Cooldown time in seconds after alert level increases before allowing another increase.
@export var alert_level_cooldown_time: float = 1.0

## Name of the SceneTree group containing the player.
@export var player_group: StringName = &"player"


func _generate_name() -> String:
	return "Manage Alert Level"


func _enter() -> void:
	pass


func _tick(delta: float) -> Status:
	# Initialize alert level if not set
	if not blackboard.has_var(alert_level_var):
		blackboard.set_var(alert_level_var, 0)

	var alert_level: int = blackboard.get_var(alert_level_var)

	# Get detection status
	var is_visible: bool = false
	if blackboard.has_var(player_visible_var):
		is_visible = blackboard.get_var(player_visible_var)
	else:
		blackboard.set_var(player_visible_var, false)

	var is_audible: bool = false
	if blackboard.has_var(player_audible_var):
		is_audible = blackboard.get_var(player_audible_var)
	else:
		blackboard.set_var(player_audible_var, false)

	# Check sight detection timer - if > 10 seconds and alert level < 2, increase alert level
	var sight_detection_timer: float = 0.0
	if blackboard.has_var(sight_detection_timer_var):
		sight_detection_timer = blackboard.get_var(sight_detection_timer_var)

	# Check and update alert level increase cooldown
	var alert_level_cooldown: float = 0.0
	if blackboard.has_var(alert_level_cooldown_var):
		alert_level_cooldown = blackboard.get_var(alert_level_cooldown_var)
	
	# Decrease cooldown timer
	if alert_level_cooldown > 0.0:
		alert_level_cooldown = max(0.0, alert_level_cooldown - delta)
		blackboard.set_var(alert_level_cooldown_var, alert_level_cooldown)
	
	var alert_level_increased_by_timer: bool = false
	var can_increase_alert_level: bool = (alert_level_cooldown <= 0.0)
	
	# Check sight detection timer - if > 10 seconds, increase alert level by 1 (max level 3)
	# Only if cooldown has expired
	if can_increase_alert_level and alert_level < 3 and sight_detection_timer > 10.0:
		alert_level = min(3, alert_level + 1)  # Only increase by 1, cap at 3
		blackboard.set_var(sight_detection_timer_var, 0.0)  # Reset detection timer
		blackboard.set_var(is_detecting_var, true)  # Set is_detecting to true
		alert_level_increased_by_timer = true
		# Start cooldown timer
		blackboard.set_var(alert_level_cooldown_var, alert_level_cooldown_time)
		# Reset decay timer when entering new alert level
		blackboard.set_var(alert_level_decay_timer_var, 0.0)
		print("Alert Level: Increased to %d - Detection timer exceeded 10 seconds (%.2fs)" % [
			alert_level, sight_detection_timer
		])

	# Check hearing gauge - if >= 100% (1.0), increase alert level by 1 (max level 3)
	# Only if we haven't already increased this frame and cooldown has expired
	if can_increase_alert_level and not alert_level_increased_by_timer:
		var hearing_gauge: float = 0.0
		if blackboard.has_var(hearing_gauge_var):
			hearing_gauge = blackboard.get_var(hearing_gauge_var)

		if alert_level < 3 and hearing_gauge >= 1.0:
			alert_level = min(3, alert_level + 1)  # Only increase by 1, cap at 3
			blackboard.set_var(hearing_gauge_var, 0.0)  # Reset hearing gauge
			alert_level_increased_by_timer = true  # Prevent other escalation logic from running
			# Start cooldown timer
			blackboard.set_var(alert_level_cooldown_var, alert_level_cooldown_time)
			# Reset decay timer when entering new alert level
			blackboard.set_var(alert_level_decay_timer_var, 0.0)

			# Get player and set as target, face player
			var players: Array[Node] = agent.get_tree().get_nodes_in_group(player_group)
			if not players.is_empty():
				var player: Node2D = players[0] as Node2D
				if is_instance_valid(player):
					# Face the player immediately
					var to_player: Vector2 = player.global_position - agent.global_position
					var direction: Vector2 = to_player.normalized()
					if agent.has_method("face_dir"):
						agent.face_dir(direction)

	# Manage detection timer for escalation
	var detection_timer: float = 0.0
	if blackboard.has_var(detection_timer_var):
		detection_timer = blackboard.get_var(detection_timer_var)

	# Increase alert level based on detection (gradual escalation)
	# Only do this if we didn't just increase alert level from detection timer and cooldown has expired
	if can_increase_alert_level and not alert_level_increased_by_timer:
		if is_visible or is_audible:
			# If currently at level 0, go to level 1 (Cautious) immediately
			if alert_level == 0:
				alert_level = 1
				detection_timer = 0.0
				# Start cooldown timer
				blackboard.set_var(alert_level_cooldown_var, alert_level_cooldown_time)
				# Reset decay timer when entering new alert level
				blackboard.set_var(alert_level_decay_timer_var, 0.0)
			# If at level 1 (Cautious), accumulate timer before going to level 2 (Investigating)
			elif alert_level == 1:
				detection_timer += delta
				if detection_timer >= detection_time_to_investigate:
					alert_level = 2
					detection_timer = 0.0
					# Start cooldown timer
					blackboard.set_var(alert_level_cooldown_var, alert_level_cooldown_time)
					# Reset decay timer when entering new alert level
					blackboard.set_var(alert_level_decay_timer_var, 0.0)
			# If at level 2 (Investigating), accumulate timer before going to level 3 (Engaged)
			elif alert_level == 2:
				detection_timer += delta
				if detection_timer >= detection_time_to_engage:
					alert_level = 3
					detection_timer = 0.0
					# Start cooldown timer
					blackboard.set_var(alert_level_cooldown_var, alert_level_cooldown_time)
					# Reset decay timer when entering new alert level
					blackboard.set_var(alert_level_decay_timer_var, 0.0)

					# Get player and face them immediately when entering engaged
					var players: Array[Node] = agent.get_tree().get_nodes_in_group(player_group)
					if not players.is_empty():
						var player: Node2D = players[0] as Node2D
						if is_instance_valid(player):
							# Face the player immediately
							var to_player: Vector2 = player.global_position - agent.global_position
							var direction: Vector2 = to_player.normalized()
							if agent.has_method("face_dir"):
								agent.face_dir(direction)
		else:
			# Reset detection timer when not detecting
			detection_timer = 0.0

	blackboard.set_var(detection_timer_var, detection_timer)

	# Store previous alert level for transition detection
	blackboard.set_var(&"previous_alert_level", alert_level)

	# Manage alert level decay timer
	# Timer resets whenever player is seen or heard, decreases when not seen/heard
	var alert_level_decay_timer: float = 0.0
	if blackboard.has_var(alert_level_decay_timer_var):
		alert_level_decay_timer = blackboard.get_var(alert_level_decay_timer_var)
	
	# Reset timer if player is seen or heard
	if is_visible or is_audible:
		alert_level_decay_timer = 0.0
		blackboard.set_var(alert_level_decay_timer_var, alert_level_decay_timer)
	else:
		# Increment timer when player is not seen or heard
		alert_level_decay_timer += delta
		blackboard.set_var(alert_level_decay_timer_var, alert_level_decay_timer)
	
	# Decrease alert level based on flat timer decay rules
	if alert_level == 3:
		# Level 3 (Engaged): If timer >= 10s without seeing/hearing → Level 2 (Investigating)
		if alert_level_decay_timer >= engaged_lose_time:
			alert_level = 2
			alert_level_decay_timer = 0.0  # Reset timer for new level
			blackboard.set_var(alert_level_decay_timer_var, alert_level_decay_timer)
	elif alert_level == 2:
		# Level 2 (Investigating): If timer >= 8s without seeing/hearing → Level 1 (Cautious)
		if alert_level_decay_timer >= investigate_lose_time:
			alert_level = 1
			alert_level_decay_timer = 0.0  # Reset timer for new level
			blackboard.set_var(alert_level_decay_timer_var, alert_level_decay_timer)
	elif alert_level == 1:
		# Level 1 (Cautious): If timer >= 5s without seeing/hearing → Level 0 (Passive)
		if alert_level_decay_timer >= cautious_lose_time:
			alert_level = 0
			alert_level_decay_timer = 0.0  # Reset timer for new level
			blackboard.set_var(alert_level_decay_timer_var, alert_level_decay_timer)

	# Update alert level
	blackboard.set_var(alert_level_var, alert_level)

	# Debug: Print pursuing player status and next move target coordinate
	var debug_tick: int = int(float(Time.get_ticks_msec()) / 2000.0)  # Every 2 seconds
	if debug_tick != get_meta("last_debug_tick", -1):
		set_meta("last_debug_tick", debug_tick)
		var is_pursuing: bool = (alert_level == 3)
		var next_move_target: Vector2 = Vector2.ZERO
		
		# Determine next move target based on detection status
		var players: Array[Node] = agent.get_tree().get_nodes_in_group(player_group)
		if not players.is_empty():
			var player: Node2D = players[0] as Node2D
			if is_instance_valid(player):
				if is_visible:
					next_move_target = player.global_position
				elif is_audible:
					if blackboard.has_var(&"sound_position"):
						next_move_target = blackboard.get_var(&"sound_position")
					else:
						next_move_target = player.global_position
				else:
					if blackboard.has_var(&"last_sight_position"):
						next_move_target = blackboard.get_var(&"last_sight_position")
					elif blackboard.has_var(&"sound_position"):
						next_move_target = blackboard.get_var(&"sound_position")
					else:
						next_move_target = player.global_position
		
		print("Manage Alert Level: pursuing_player=%s, next_move_target=%s, alert_level=%d, visible=%s, audible=%s" % [
			is_pursuing, next_move_target, alert_level, is_visible, is_audible
		])

	# Return RUNNING to keep detection sequence active continuously
	return RUNNING
