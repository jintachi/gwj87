#*
#* player.gd
#* =============================================================================
#* Simple player movement script with WASD controls.
#* =============================================================================
#*
extends CharacterBody2D

## Fixed interval between footstep sounds (in seconds).
const FOOTSTEP_INTERVAL: float = 0.6

## Movement speed in pixels per second.
@export var speed: float = 200.0

## Acceleration factor for smooth movement.
@export var acceleration: float = 10.0

## Friction factor when not moving.
@export var friction: float = 10.0

## Whether the player is in stealth mode (affects noise level).
@export var is_stealth: bool = false

## Noise level (0.0 = silent, 1.0 = loud).
var noise_level: float = 0.0

## Current facing direction (-1.0 = left, 1.0 = right).
## For top-down games, this tracks the last horizontal movement direction.
var _facing: float = 1.0

## Last movement direction (for top-down facing).
var _last_movement_direction: Vector2 = Vector2.RIGHT

## Queue of sound events for AI detection.
var _sound_events: Array[Dictionary] = []

## Time since last footstep sound.
var _footstep_timer: float = 0.0


func _ready() -> void:
	# Ensure player is in the player group for enemy detection
	if not is_in_group("player"):
		add_to_group("player")

	# Initialize input actions if they don't exist
	_init_input_actions()


func _physics_process(delta: float) -> void:
	_handle_movement(delta)
	_update_noise_level()


func _process(delta: float) -> void:
	pass


func _handle_movement(delta: float) -> void:
	# Get input direction
	var input_vector := Vector2.ZERO

	if Input.is_action_pressed("move_left"):
		input_vector.x -= 1.0
	if Input.is_action_pressed("move_right"):
		input_vector.x += 1.0
	if Input.is_action_pressed("move_up"):
		input_vector.y -= 1.0
	if Input.is_action_pressed("move_down"):
		input_vector.y += 1.0

	# Normalize diagonal movement
	input_vector = input_vector.normalized()

	# Calculate desired velocity
	var desired_velocity := input_vector * speed

	# Apply acceleration or friction
	if input_vector.length() > 0.0:
		velocity = velocity.lerp(desired_velocity, acceleration * delta)
		# Update facing direction based on movement (for top-down)
		# Track last movement direction
		_last_movement_direction = input_vector
		# For horizontal facing (used by AI), prioritize horizontal movement
		if abs(input_vector.x) > abs(input_vector.y):
			_facing = signf(input_vector.x)
		# If moving primarily vertically, keep last horizontal facing
	else:
		velocity = velocity.lerp(Vector2.ZERO, friction * delta)

	# Move the character
	move_and_slide()


func _update_noise_level() -> void:
	# Calculate noise based on movement speed
	# Stealthy players move slowly to avoid detection
	var current_speed := velocity.length()
	if is_stealth:
		# In stealth mode, noise is reduced
		if current_speed > 100.0:  # Running - moderate noise
			noise_level = 0.5
		elif current_speed > 30.0:  # Walking - quiet
			noise_level = 0.2
		else:  # Slow movement - very quiet
			noise_level = 0.1
	else:
		# Normal mode - full noise
		if current_speed > 150.0:  # Running - loud
			noise_level = 1.0
		elif current_speed > 50.0:  # Walking - moderate noise
			noise_level = 0.6
		elif current_speed > 10.0:  # Slow movement - quiet
			noise_level = 0.3
		else:  # Standing still - silent
			noise_level = 0.0

## Get the current noise level (used by enemy hearing detection).
func get_noise_level() -> float:
	return noise_level


## Returns 1.0 when player is facing right, -1.0 when facing left.
## For top-down games, this tracks the last significant horizontal movement.
## Used by AI scripts for consistency with agent_base interface.
func get_facing() -> float:
	return _facing


## Returns the last movement direction as a normalized Vector2.
## Useful for top-down games where you need the actual movement direction.
func get_movement_direction() -> Vector2:
	if _last_movement_direction.length() > 0.0:
		return _last_movement_direction.normalized()
	return Vector2.RIGHT


## Emit a sound event (for AI detection).
## Call this when player makes sounds like footsteps, shooting, etc.
## volume: Awareness increase value (0-300 scale, typically 5-30)
## sound_pos: Position where sound was emitted (defaults to player position)
## radius: Maximum hearing range for this sound (defaults to 300.0)
func emit_sound(value:float = 1, sound_pos: Vector2 = Vector2.ZERO, radius: float = 300.0) -> void:
	if sound_pos == Vector2.ZERO:
		sound_pos = global_position
	_sound_events.append({
		"position": sound_pos,
		"value": value,
		"radius": radius,
		"time": Time.get_ticks_msec(),
		"id": str(Time.get_ticks_msec()) + "_" + str(sound_pos)  # Unique ID for tracking
	})
	# Keep only recent sounds (last 1.0 seconds to give AI time to process)
	var current_time: int = Time.get_ticks_msec()
	_sound_events = _sound_events.filter(func(event): return current_time - event.time < 1000)


## Get sound events for AI detection.
## Returns array of dictionaries with "position", "value", "radius", and "id" keys.
func get_sound_events() -> Array:
	return _sound_events.duplicate()

func _init_input_actions() -> void:
	# Create input actions if they don't exist
	var actions := [
		{"name": "move_left", "key": KEY_A},
		{"name": "move_right", "key": KEY_D},
		{"name": "move_up", "key": KEY_W},
		{"name": "move_down", "key": KEY_S}
	]

	for action in actions:
		if not InputMap.has_action(action.name):
			InputMap.add_action(action.name)
			var event := InputEventKey.new()
			event.keycode = action.key
			InputMap.action_add_event(action.name, event)
