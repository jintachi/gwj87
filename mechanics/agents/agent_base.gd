#*
#* agent_base.gd
#* =============================================================================
#* Base class for all AI agents. Provides movement, facing, and health management.
#* =============================================================================
#*
extends CharacterBody2D
class_name AgentBase

## Movement speed in pixels per second.
@export var speed: float = 200.0

## Current facing direction (-1.0 = left, 1.0 = right).
## Kept for backward compatibility with AI tasks that expect this format.
var _facing: float = 1.0

## Current facing direction as a normalized Vector2 (for top-down games).
var _facing_direction: Vector2 = Vector2.RIGHT

## Health component (optional).
var health: Node

## Node to rotate for visual facing (usually Root or a visual node).
@export var facing_node: Node2D

## Desired velocity for movement (set by AI tasks, applied in _physics_process).
## This is the single source of truth for movement commands.
var _desired_velocity: Vector2 = Vector2.ZERO


func _ready() -> void:
	# Find health component if it exists
	health = get_node_or_null("Health")
	
	# Find facing node if not set
	if not facing_node:
		facing_node = get_node_or_null("Root")
		if not facing_node:
			facing_node = self


func _physics_process(_delta: float) -> void:
	# Apply movement - this is the SINGLE location where movement is applied
	# AI tasks should call set_desired_velocity() or move() to set _desired_velocity
	# Tasks run during _process() or behavior tree update, which happens before _physics_process()
	
	# Debug: Print movement command occasionally (only for stealth enemies)
	if name.contains("StealthEnemy") or name.contains("Stealth"):
		var debug_tick: int = int(Time.get_ticks_msec() / 2000)  # Every 2 seconds
		if debug_tick != get_meta("last_movement_debug_tick", -1):
			set_meta("last_movement_debug_tick", debug_tick)
			if _desired_velocity.length() > 0.1:
				print("AgentBase: Applying movement - velocity=%s, speed=%.0f" % [
					_desired_velocity, _desired_velocity.length()
				])
			else:
				print("AgentBase: No movement command (velocity=ZERO)")
	
	velocity = _desired_velocity
	move_and_slide()
	
	# Update facing based on actual movement
	update_facing()
	
	# Reset desired velocity AFTER applying it
	# This ensures that if no task sets it next frame, the agent stops
	# Tasks must call move() or set_desired_velocity() every frame to continue moving
	_desired_velocity = Vector2.ZERO


## Set the desired velocity for movement.
## This is the preferred method for AI tasks to request movement.
## Movement is applied in _physics_process() to ensure single source of truth.
## IMPORTANT: Tasks must call this every frame to continue moving.
## @param p_velocity: The desired velocity vector.
func set_desired_velocity(p_velocity: Vector2) -> void:
	_desired_velocity = p_velocity


## Move the agent with the given velocity.
## DEPRECATED: Use set_desired_velocity() instead.
## This method is kept for backward compatibility but will be removed.
## It now just sets the desired velocity, which is applied in _physics_process().
func move(p_velocity: Vector2) -> void:
	set_desired_velocity(p_velocity)


## Update facing direction based on current velocity.
## For top-down games, this rotates the agent to face movement direction.
func update_facing() -> void:
	if velocity.length() > 0.1:
		# Update facing direction based on velocity
		_facing_direction = velocity.normalized()
		
		# Calculate rotation angle (in radians)
		var angle: float = _facing_direction.angle()
		
		# Rotate the facing node
		if facing_node:
			facing_node.rotation = angle
		
		# Update legacy _facing for backward compatibility
		_facing = signf(velocity.x) if abs(velocity.x) > 0.1 else _facing


## Get the current facing direction.
## Returns 1.0 when facing right, -1.0 when facing left.
## Kept for backward compatibility.
func get_facing() -> float:
	return _facing


## Get the current facing direction as a Vector2.
## Returns a normalized Vector2 pointing in the direction the agent is facing.
func get_facing_direction() -> Vector2:
	return _facing_direction


## Set the facing direction directly.
## @param dir: -1.0 for left, 1.0 for right, or a Vector2 for full direction.
func face_dir(dir) -> void:
	if dir is Vector2:
		# Vector2 direction
		if dir.length() > 0.1:
			_facing_direction = dir.normalized()
			var angle: float = _facing_direction.angle()
			if facing_node:
				facing_node.rotation = angle
			_facing = signf(dir.x) if abs(dir.x) > 0.1 else _facing
	else:
		# Legacy float direction (-1.0 or 1.0)
		_facing = signf(dir)
		_facing_direction = Vector2(_facing, 0.0)
		if facing_node:
			facing_node.rotation = _facing_direction.angle()


## Get the health component if it exists.
func get_health() -> Node:
	return health


## Take damage (if health component exists).
func take_damage(amount: float) -> void:
	if health and health.has_method("take_damage"):
		health.take_damage(amount)

