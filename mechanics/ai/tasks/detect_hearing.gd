#*
#* detect_hearing.gd
#* =============================================================================
#* Hearing detection - listens for SoundEvent signals from the player.
#* =============================================================================
#*
@tool
extends BTAction
## Listens for SoundEvent signals from the player. [br]
## If sound is within hearing range, increases awareness with 50% falloff at max range. [br]
## If sound is outside hearing range, ignores it. [br]
## Returns [code]RUNNING[/code] always (doesn't block sequence).

## Name of the SceneTree group containing the player.
@export var player_group: StringName = &"player"

## Maximum hearing range.
@export var hearing_range: float = 150.0

## Blackboard variable to store if player is audible (bool).
@export var player_audible_var: StringName = &"player_audible"

## Blackboard variable to store last hearing time (float, seconds since last sound).
@export var last_hearing_time_var: StringName = &"last_hearing_time"

## Blackboard variable to store sound position (Vector2).
@export var sound_position_var: StringName = &"sound_position"

## Blackboard variable to store awareness (float, 0-300).
@export var awareness_var: StringName = &"awareness"

## Reference to the player node.
var _player: Node = null

## Track if we're connected to the player's sound signal.
var _is_connected: bool = false


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
	if not blackboard.has_var(awareness_var):
		blackboard.set_var(awareness_var, 0.0)
	
	# Find and connect to player
	_connect_to_player()


func _exit() -> void:
	# Disconnect from player when task exits
	_disconnect_from_player()


func _tick(delta: float) -> Status:
	# Update last hearing time
	var last_hearing_time: float = 0.0
	if blackboard.has_var(last_hearing_time_var):
		last_hearing_time = blackboard.get_var(last_hearing_time_var)
	
	# Check if player is still valid and connected
	if not is_instance_valid(_player) or not _is_connected:
		blackboard.set_var(player_audible_var, false)
		_handle_not_audible(delta)
		# Try to reconnect
		_connect_to_player()
		return RUNNING
	
	# Update last hearing time
	last_hearing_time += delta
	blackboard.set_var(last_hearing_time_var, last_hearing_time)
	
	# If no sounds have been heard for a short time (0.1 seconds), set player_audible to false
	# This allows manage_awareness to start decay when player stops making sounds
	if last_hearing_time > 0.1:
		blackboard.set_var(player_audible_var, false)
	
	# Return RUNNING to keep detection active continuously
	return RUNNING


## Connects to the player's sound signal.
func _connect_to_player() -> void:
	# Disconnect from previous player if any
	_disconnect_from_player()
	
	# Find player
	var players: Array[Node] = agent.get_tree().get_nodes_in_group(player_group)
	if players.is_empty():
		return
	
	_player = players[0]
	if not is_instance_valid(_player):
		return
	
	# Check if player has the sound signal (from LivingEntity)
	if not _player.has_signal("sound"):
		push_warning("Player does not have 'sound' signal")
		return
	
	# Connect to sound signal (signal emits: position, level)
	if _player.sound.connect(_on_player_sound) == OK:
		_is_connected = true


## Disconnects from the player's sound signal.
func _disconnect_from_player() -> void:
	if is_instance_valid(_player) and _is_connected:
		if _player.has_signal("sound"):
			_player.sound.disconnect(_on_player_sound)
		_is_connected = false
	_player = null


## Called when player emits a sound event.
## Signal emits: position (Vector2), level (float)
func _on_player_sound(sound_position: Vector2, sound_level: float) -> void:
	# If no position, use player position as fallback
	if sound_position == Vector2.ZERO and is_instance_valid(_player):
		sound_position = _player.global_position
	
	# Calculate distance to sound
	var distance: float = agent.global_position.distance_to(sound_position)
	
	# If outside hearing range, ignore it
	if distance > hearing_range:
		return
	
	# Calculate awareness increase with 50% falloff at max hearing range
	# At distance 0: awareness = level * 1.0
	# At distance = hearing_range: awareness = level * 0.5
	# Linear interpolation: awareness = level * (1.0 - 0.5 * (distance / hearing_range))
	var distance_ratio: float = distance / hearing_range
	var falloff_factor: float = 1.0 - (0.5 * distance_ratio)
	var awareness_increase: float = sound_level * falloff_factor
	
	# Get current awareness and increase it
	var awareness: float = 0.0
	if blackboard.has_var(awareness_var):
		awareness = blackboard.get_var(awareness_var)
	
	awareness += awareness_increase
	awareness = min(awareness, 300.0)  # Cap at 300
	blackboard.set_var(awareness_var, awareness)
	print("player HEARD, increasing awareness by: " + str(awareness_increase))
	
	# Update blackboard variables
	blackboard.set_var(player_audible_var, true)
	blackboard.set_var(sound_position_var, sound_position)
	blackboard.set_var(last_hearing_time_var, 0.0)  # Reset timer when sound is heard


func _handle_not_audible(delta: float) -> void:
	# Increment time since last hearing
	var last_hearing_time: float = 0.0
	if blackboard.has_var(last_hearing_time_var):
		last_hearing_time = blackboard.get_var(last_hearing_time_var)
	blackboard.set_var(last_hearing_time_var, last_hearing_time + delta)
