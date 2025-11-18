#*
#* announce_to_enemies.gd
#* =============================================================================
#* Alert Level 2: Tracking - Announces player location to nearby enemies.
#* Only original detecting enemy communicates, and only once per alert level 2 entry.
#* =============================================================================
#*
@tool
extends BTAction
## Shares last_known_player_location with nearby enemies. [br]
## Only runs when enemy reaches alert level 2 from own detection. [br]
## Returns [code]RUNNING[/code] always (doesn't block sequence). [br]
## Returns [code]SUCCESS[/code] if alert level != 2 (exits early).

## Blackboard variable for alert level (int).
@export var alert_level_var: StringName = &"alert_level"

## Blackboard variable for last sight position (Vector2).
@export var last_sight_position_var: StringName = &"last_sight_position"

## Blackboard variable for last known player location (Vector2).
@export var last_known_player_location_var: StringName = &"last_known_player_location"

## Blackboard variable to track if communication was sent (bool).
@export var communication_sent_var: StringName = &"communication_sent"

## Blackboard variable for previous alert level (int).
@export var previous_alert_level_var: StringName = &"previous_alert_level"

## Name of the SceneTree group containing enemies.
@export var enemy_group: StringName = &"stealth_enemies"

## Communication radius in pixels.
@export var communication_radius: float = 500.0

## Target alert level required for this task (should be 2 for tracking).
@export var required_alert_level: int = 2


func _generate_name() -> String:
	return "Announce to Enemies  radius: %.0f" % communication_radius


func _enter() -> void:
	# Initialize communication flag if not set
	if not blackboard.has_var(communication_sent_var):
		blackboard.set_var(communication_sent_var, false)
	if not blackboard.has_var(previous_alert_level_var):
		blackboard.set_var(previous_alert_level_var, 0)


func _tick(_delta: float) -> Status:
	# Check alert level first
	var alert_level: int = 0
	if blackboard.has_var(alert_level_var):
		alert_level = blackboard.get_var(alert_level_var)
	
	if alert_level != required_alert_level:
		# Not at tracking level, reset communication flag
		blackboard.set_var(communication_sent_var, false)
		blackboard.set_var(previous_alert_level_var, alert_level)
		return SUCCESS
	
	# Get previous alert level
	var previous_alert_level: int = 0
	if blackboard.has_var(previous_alert_level_var):
		previous_alert_level = blackboard.get_var(previous_alert_level_var)
	
	# Only communicate if we just entered alert level 2 from our own detection
	# (not from another enemy's communication)
	var communication_sent: bool = false
	if blackboard.has_var(communication_sent_var):
		communication_sent = blackboard.get_var(communication_sent_var)
	
	# Check if we just entered alert level 2 (transitioned from level 1 or below)
	var just_entered_level_2: bool = (alert_level == required_alert_level and previous_alert_level < required_alert_level)
	
	if just_entered_level_2 and not communication_sent:
		# Get last known player location (prefer sight position)
		var last_known_location: Vector2 = Vector2.ZERO
		
		if blackboard.has_var(last_sight_position_var):
			last_known_location = blackboard.get_var(last_sight_position_var)
		
		if last_known_location == Vector2.ZERO:
			# Fallback to sound position if no sight position
			if blackboard.has_var(&"sound_position"):
				last_known_location = blackboard.get_var(&"sound_position")
		
		if last_known_location != Vector2.ZERO:
			# Set our own last known player location
			blackboard.set_var(last_known_player_location_var, last_known_location)
			
			# Find nearby enemies in the same scene tree
			var enemies: Array[Node] = agent.get_tree().get_nodes_in_group(enemy_group)
			
			for enemy_node in enemies:
				if not is_instance_valid(enemy_node):
					continue
				
				# Skip ourselves
				if enemy_node == agent:
					continue
				
				# Check distance
				var distance: float = agent.global_position.distance_to(enemy_node.global_position)
				if distance > communication_radius:
					continue
				
				# Get enemy's blackboard (assuming enemy has BTPlayer)
				var bt_player = enemy_node.get_node_or_null("BTPlayer")
				if bt_player and bt_player.has_method("get_blackboard"):
					var enemy_blackboard = bt_player.get_blackboard()
					if enemy_blackboard:
						# Share last known player location
						enemy_blackboard.set_var(last_known_player_location_var, last_known_location)
						
						# Increase enemy's awareness to trigger alert level 2
						# (they should already be close, so give them awareness to reach level 2)
						if enemy_blackboard.has_var(&"awareness"):
							var enemy_awareness: float = enemy_blackboard.get_var(&"awareness")
							# Set awareness to just above threshold for level 2 (200)
							enemy_awareness = max(enemy_awareness, 201.0)
							enemy_awareness = min(enemy_awareness, 300.0)  # Cap at 300
							enemy_blackboard.set_var(&"awareness", enemy_awareness)
			
			# Mark communication as sent
			blackboard.set_var(communication_sent_var, true)
	
	# Update previous alert level
	blackboard.set_var(previous_alert_level_var, alert_level)
	
	return RUNNING
