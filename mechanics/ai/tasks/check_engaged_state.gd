#*
#* check_engaged_state.gd
#* =============================================================================
#* Checks if NPC should be in Engaged state (has target and can see/hear them).
#* Also checks if should transition from Alert to Engaged based on audio gauge.
#* =============================================================================
#*
@tool
extends BTAction
## Checks if the NPC should be in Engaged state. [br]
## Returns [code]SUCCESS[/code] if target exists and is visible/audible, or if audio gauge is full while in Alert. [br]
## Returns [code]FAILURE[/code] if no target or target lost.

## Blackboard variable that stores the target node (Node2D).
@export var target_var: StringName = &"target"

## Blackboard variable that stores the "lose target" timer.
@export var lose_target_timer_var: StringName = &"lose_target_timer"

## Time in seconds before losing target when not visible/audible.
@export var lose_target_time: float = 7.0

## Name of the SceneTree group containing the player.
@export var player_group: StringName = &"player"

## Maximum vision range for checking if target is visible.
@export var vision_range: float = 400.0

## Maximum hearing range for checking if target is audible.
@export var hearing_range: float = 300.0

## Blackboard variable that stores the audio gauge (0.0-1.0).
@export var audio_gauge_var: StringName = &"audio_gauge"

## Blackboard variable that stores current NPC state.
@export var npc_state_var: StringName = &"npc_state"

## Blackboard variable that stores the sound position (Vector2).
@export var sound_position_var: StringName = &"sound_position"


func _generate_name() -> String:
	return "Check Engaged State (lose after %.1fs)" % lose_target_time


func _tick(delta: float) -> Status:
	# First, check if we should transition from Alert to Engaged based on audio gauge
	var current_state: String = "Passive"
	if blackboard.has_var(npc_state_var):
		current_state = blackboard.get_var(npc_state_var)
	
	var gauge: float = 0.0
	if blackboard.has_var(audio_gauge_var):
		gauge = blackboard.get_var(audio_gauge_var)
	
	# If in Alert state and audio gauge is full, transition to Engaged
	if current_state == "Alert" and gauge >= 1.0:
		# Set target from sound position if we don't have one
		var target: Node2D = null
		if blackboard.has_var(target_var):
			target = blackboard.get_var(target_var) as Node2D
		
		if not is_instance_valid(target):
			# Try to get player from sound position
			var sound_pos: Vector2 = Vector2.ZERO
			if blackboard.has_var(sound_position_var):
				sound_pos = blackboard.get_var(sound_position_var)
			
			if sound_pos != Vector2.ZERO:
				# Find closest player to sound position
				var players: Array[Node] = agent.get_tree().get_nodes_in_group(player_group)
				if not players.is_empty():
					var closest_player: Node2D = null
					var closest_distance: float = INF
					for player in players:
						if is_instance_valid(player):
							var dist: float = player.global_position.distance_to(sound_pos)
							if dist < closest_distance:
								closest_distance = dist
								closest_player = player as Node2D
					
					if closest_player:
						blackboard.set_var(target_var, closest_player)
						print("Engaged State: Transitioned from Alert to Engaged via audio gauge, set target to %s" % closest_player.name)
						return SUCCESS
	
	# Now check if we have a valid target
	var target: Node2D = null
	if blackboard.has_var(target_var):
		target = blackboard.get_var(target_var) as Node2D
	
	# No target - not engaged
	if not is_instance_valid(target):
		# Reset timer
		if blackboard.has_var(lose_target_timer_var):
			blackboard.set_var(lose_target_timer_var, 0.0)
		return FAILURE
	
	# Check if target is visible or audible
	var to_target: Vector2 = target.global_position - agent.global_position
	var distance: float = to_target.length()
	
	var is_visible: bool = false
	var is_audible: bool = false
	
	# Check visibility (simple range check - full vision check is in vision detection)
	if distance <= vision_range:
		# Check line of sight
		var space_state = agent.get_world_2d().direct_space_state
		var query := PhysicsRayQueryParameters2D.create(
			agent.global_position,
			target.global_position
		)
		query.collision_mask = 1  # Obstacle layer
		query.exclude = [agent.get_rid()]
		if target is CharacterBody2D or target is RigidBody2D or target is Area2D:
			query.exclude.append(target.get_rid())
		
		var result = space_state.intersect_ray(query)
		# No obstacles = visible (or hit the target itself)
		if result.is_empty():
			is_visible = true
		else:
			var collider = result.get("collider", null)
			if collider == target:
				is_visible = true
	
	# Check audibility
	if distance <= hearing_range:
		# Check if target is making noise
		if target.has_method("get_noise_level"):
			var noise_level: float = target.get_noise_level()
			if noise_level > 0.0:
				is_audible = true
		
		# Also check sound events
		if target.has_method("get_sound_events"):
			var sound_events: Array = target.get_sound_events()
			if not sound_events.is_empty():
				is_audible = true
	
	# If target is visible or audible, reset timer and stay engaged
	if is_visible or is_audible:
		if blackboard.has_var(lose_target_timer_var):
			blackboard.set_var(lose_target_timer_var, 0.0)
		return SUCCESS
	
	# Target not visible or audible - increment lose timer
	var lose_timer: float = 0.0
	if blackboard.has_var(lose_target_timer_var):
		lose_timer = blackboard.get_var(lose_target_timer_var)
	
	lose_timer += delta
	blackboard.set_var(lose_target_timer_var, lose_timer)
	
	# If timer exceeded, lose target
	if lose_timer >= lose_target_time:
		# Clear target and reset timer
		blackboard.set_var(target_var, null)
		blackboard.set_var(lose_target_timer_var, 0.0)
		print("Engaged State: Lost target after %.1f seconds" % lose_timer)
		return FAILURE
	
	# Still engaged but losing track
	return SUCCESS
