#*
#* moving_platform.gd
#* =============================================================================
#* Moving platform that follows waypoints linearly, moving entities inside it.
#* =============================================================================
#*
extends Node2D

## Array of waypoint positions to follow.
@export var waypoints: Array[Vector2] = []

## Movement speed between waypoints in pixels per second.
@export var speed: float = 100.0

## Time to wait at waypoints in seconds.
@export var wait_time: float = 1.0

## Whether to loop (true) or reverse direction (false) at endpoints.
@export var loop: bool = true

## Current waypoint index.
var _current_waypoint_index: int = 0

## Movement direction (1 = forward, -1 = backward).
var _direction: int = 1

## Time remaining in wait state at waypoint.
var _wait_timer: float = 0.0

## Whether currently waiting at a waypoint.
var _is_waiting: bool = false

## Entities detected inside the platform (for manual movement).
var _on_platform_entities: Array[Node2D] = []

## Previous frame's position (for calculating movement delta).
var _last_position: Vector2 = Vector2.ZERO

## Initial global position of the platform (used for waypoint conversion).
var _initial_global_position: Vector2 = Vector2.ZERO

## Reference to the detection Area2D.
@onready var _detection_area: Area2D = $DetectionArea


func _ready() -> void:

	position = Vector2.ZERO

	# Connect Area2D signals for entity detection
	if _detection_area:
		_detection_area.body_entered.connect(_on_body_entered)
		_detection_area.body_exited.connect(_on_body_exited)
	else:
		push_warning("MovingPlatform: DetectionArea not found! Manual entity movement will not work.")
	
	# Validate waypoints
	if waypoints.is_empty():
		push_error("MovingPlatform: No waypoints assigned! Please add waypoints in the inspector.")
		return
	
	# Store initial global position (before any movement)
	_initial_global_position = global_position
	
	# Initialize position to first waypoint (convert from local to global)
	# Waypoints are relative to the platform's initial position
	global_position = _initial_global_position + waypoints[0]
	_last_position = global_position


func _physics_process(delta: float) -> void:
	# Validate waypoints
	if waypoints.is_empty():
		return
	
	# Handle waiting at waypoints
	if _is_waiting:
		_wait_timer -= delta
		if _wait_timer <= 0.0:
			_is_waiting = false
		else:
			# Don't move while waiting
			_apply_manual_movement(Vector2.ZERO)
			return
	
	# Get current target waypoint (convert from local to global)
	# Waypoints are relative to the platform's initial position, not current position
	var target_waypoint: Vector2 = _initial_global_position + waypoints[_current_waypoint_index]
	
	# Calculate distance to target
	var distance_to_target: float = global_position.distance_to(target_waypoint)
	
	# Calculate movement distance this frame
	var move_distance: float = speed * delta
	
	# Check if we've reached the waypoint
	if distance_to_target <= move_distance:
		# Reached the waypoint - snap to it
		var movement_delta: Vector2 = target_waypoint - global_position
		_last_position = global_position
		global_position = target_waypoint
		_apply_manual_movement(movement_delta)
		
		# Move to next waypoint
		_advance_to_next_waypoint()
	else:
		# Move towards target waypoint
		var direction_to_target: Vector2 = (target_waypoint - global_position).normalized()
		var movement_delta: Vector2 = direction_to_target * move_distance
		
		_last_position = global_position
		global_position += movement_delta
		_apply_manual_movement(movement_delta)


## Advance to the next waypoint based on loop/reverse settings.
func _advance_to_next_waypoint() -> void:
	_current_waypoint_index += _direction
	
	# Handle endpoints
	if _current_waypoint_index >= waypoints.size():
		if loop:
			# Loop: wrap around to start
			_current_waypoint_index = 0
		else:
			# Reverse: go back to last waypoint and change direction
			_current_waypoint_index = waypoints.size() - 1
			_direction = -1
			_start_wait()
	elif _current_waypoint_index < 0:
		if not loop:
			# Reverse: go to first waypoint and change direction
			_current_waypoint_index = 0
			_direction = 1
			_start_wait()
	
	# Start waiting at waypoint if configured
	if wait_time > 0.0:
		_start_wait()


## Start waiting at a waypoint.
func _start_wait() -> void:
	_is_waiting = true
	_wait_timer = wait_time


## Apply movement to entities detected inside the platform.
func _apply_manual_movement(movement_delta: Vector2) -> void:
	if movement_delta.length() <= 0.0:
		return
	
	# Move all detected entities by the same delta
	for entity in _on_platform_entities:
		if not is_instance_valid(entity):
			continue
		
		# Apply movement delta to entity
		entity.global_position += movement_delta


## Called when an entity enters the detection area.
func _on_body_entered(body: Node2D) -> void:
	# Ignore the platform itself
	if body == self:
		return
	
	if body is Player:
		body.on_moving_platform = true
	
	# Add to tracking array if not already present
	if body not in _on_platform_entities:
		_on_platform_entities.append(body)


## Called when an entity exits the detection area.
func _on_body_exited(body: Node2D) -> void:
	# Remove from tracking array
	var index: int = _on_platform_entities.find(body)
	if index >= 0:
		_on_platform_entities.remove_at(index)
		
	if body is Player:
		body.on_moving_platform = false
