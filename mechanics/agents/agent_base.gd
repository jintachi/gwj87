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
	
	velocity = _desired_velocity
	move_and_slide()
	
	# Update facing based on actual movement
	update_facing()
	_desired_velocity = Vector2.ZERO


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

func get_facing() -> float:
	return _facing

func get_facing_direction() -> Vector2:
	return _facing_direction


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
