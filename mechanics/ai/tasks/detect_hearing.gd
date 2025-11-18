#*
#* detect_hearing.gd
#* =============================================================================
#* Hearing detection - checks if player is audible and increases awareness.
#* =============================================================================
#*
@tool
extends BTAction
## Checks if player is audible through sound. [br]
## Increases awareness based on sound value with distance falloff. [br]
## Each sound event only increases awareness once. [br]
## Sets blackboard variables for hearing detection status. [br]
## Returns [code]RUNNING[/code] always (doesn't block sequence).

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

## Blackboard variable to store awareness (float, 0-300).
@export var awareness_var: StringName = &"awareness"

## Blackboard variable to store hearing cooldown timer (float).
@export var hearing_cooldown_var: StringName = &"hearing_cooldown"

## Blackboard variable to store processed sound IDs (Array).
@export var processed_sound_ids_var: StringName = &"processed_sound_ids"

## Cooldown time in seconds between awareness increases from hearing.
@export var hearing_cooldown_time: float = 0.2


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
	if not blackboard.has_var(hearing_cooldown_var):
		blackboard.set_var(hearing_cooldown_var, 0.0)
	if not blackboard.has_var(processed_sound_ids_var):
		blackboard.set_var(processed_sound_ids_var, [])


func _tick(delta: float) -> Status:
	var players: Array[Node] = agent.get_tree().get_nodes_in_group(player_group)
	
	var is_audible: bool = false
	var sound_pos: Vector2 = Vector2.ZERO
	
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

	# Check range
	if distance > hearing_range:
		blackboard.set_var(player_audible_var, false)
		_handle_not_audible(delta)
		return RUNNING
	
	# Get processed sound IDs
	var processed_sound_ids: Array = []
	if blackboard.has_var(processed_sound_ids_var):
		var stored_ids = blackboard.get_var(processed_sound_ids_var)
		if stored_ids is Array:
			processed_sound_ids = stored_ids
	
	# Check sound events - each sound event only increases awareness once
	if player.has_method("get_sound_events"):
		var sound_events: Array = player.get_sound_events()
		
		for sound_event in sound_events:
			if not sound_event is Dictionary:
				continue
			
			# Get sound ID (assume it has an 'id' field for tracking)
			var sound_id = sound_event.get("id", null)
			if sound_id == null:
				# If no ID, use position as unique identifier
				if sound_event.has("position"):
					sound_id = str(sound_event.position)
				else:
					continue
			
			# Skip if already processed
			if sound_id in processed_sound_ids:
				continue
			
			# Process new sound event
			# Support both "value" and "volume" keys for backward compatibility
			var sound_value: float = sound_event.get("value", sound_event.get("volume", 10.0))
			var sound_radius: float = sound_event.get("radius", hearing_range)
			var event_position: Vector2 = sound_event.get("position", player.global_position)
			
			# Calculate distance falloff
			var event_distance: float = agent.global_position.distance_to(event_position)
			if event_distance > sound_radius:
				continue  # Sound is outside its radius
			
			# Calculate falloff (linear from full value at distance 0 to 0 at sound_radius)
			var falloff_factor: float = 1.0 - (event_distance / sound_radius)
			falloff_factor = max(0.0, falloff_factor)  # Clamp to 0-1
			
			var awareness_increase: float = sound_value * falloff_factor
			
			# Update hearing cooldown
			var hearing_cooldown: float = 0.0
			if blackboard.has_var(hearing_cooldown_var):
				hearing_cooldown = blackboard.get_var(hearing_cooldown_var)
			
			# Decrease cooldown timer
			if hearing_cooldown > 0.0:
				hearing_cooldown = max(0.0, hearing_cooldown - delta)
				blackboard.set_var(hearing_cooldown_var, hearing_cooldown)
			
			# Increase awareness if cooldown has expired
			if hearing_cooldown <= 0.0:
				var awareness: float = 0.0
				if blackboard.has_var(awareness_var):
					awareness = blackboard.get_var(awareness_var)
				
				awareness += awareness_increase
				awareness = min(awareness, 300.0)  # Cap at 300
				blackboard.set_var(awareness_var, awareness)
				
				# Start cooldown
				blackboard.set_var(hearing_cooldown_var, hearing_cooldown_time)
			
			# Mark sound as processed
			processed_sound_ids.append(sound_id)
			
			# Update sound position
			sound_pos = event_position
			is_audible = true
			
			# Limit processed sounds array size (keep last 50)
			if processed_sound_ids.size() > 50:
				processed_sound_ids = processed_sound_ids.slice(-50)
			
			blackboard.set_var(processed_sound_ids_var, processed_sound_ids)
	
	# Check if player is making continuous noise
	var noise_level: float = 0.0
	if player.has_method("get_noise_level"):
		noise_level = player.get_noise_level()
	
	if noise_level > 0.0:
		is_audible = true
		if sound_pos == Vector2.ZERO:
			sound_pos = player.global_position
		
		# For continuous noise, treat it differently - just update position
		# Awareness increase from continuous noise would be handled by sound events
	
	blackboard.set_var(player_audible_var, is_audible)

	if is_audible:
		blackboard.set_var(last_hearing_time_var, 0.0)
		blackboard.set_var(sound_position_var, sound_pos)
	else:
		_handle_not_audible(delta)

	# Return RUNNING to keep detection active continuously
	return RUNNING


func _handle_not_audible(delta: float) -> void:
	# Increment time since last hearing
	var last_hearing_time: float = 0.0
	if blackboard.has_var(last_hearing_time_var):
		last_hearing_time = blackboard.get_var(last_hearing_time_var)
	blackboard.set_var(last_hearing_time_var, last_hearing_time + delta)
