#*
#* move_to.gd
#* =============================================================================
#* Moves the entity to a target position stored in the blackboard.
#* =============================================================================
#*
@tool
extends BTAction
## Moves toward a target position stored in the blackboard. [br]
## Returns [code]RUNNING[/code] while moving. [br]
## Returns [code]SUCCESS[/code] when the target position is reached. [br]
## Returns [code]FAILURE[/code] if no target position is available.

## Blackboard variable for target position (Vector2).
@export var target_position_var: StringName = &"target_position"

## Blackboard variable for desired speed (float).
@export var speed_var: StringName = &"speed"

## How close to get to the target position before considering it reached.
@export var arrival_tolerance: float = 30.0


func _generate_name() -> String:
	return "Move To"


func _enter() -> void:
	pass


func _tick(_delta: float) -> Status:
	var target_position: Vector2 = blackboard.get_var(target_position_var, Vector2.ZERO, false)
	var speed: float = blackboard.get_var(speed_var, 200.0, false)
	
	if target_position == Vector2.ZERO:
		agent.move(Vector2.ZERO, -1.0)
		return FAILURE
	
	var distance_to_target: float = agent.global_position.distance_to(target_position)
	if distance_to_target < arrival_tolerance:
		# Reached target, stop movement
		# Pass -1.0 as delta to use AI task path (velocity mode)
		agent.move(Vector2.ZERO, -1.0)
		return SUCCESS
	
	# Calculate direction and velocity toward target
	var direction: Vector2 = agent.global_position.direction_to(target_position)
	var velocity: Vector2 = direction * speed
	
	# Pass velocity with delta < 0 to use AI task path in flyer_bot.gd
	# This will set self_velocity directly
	agent.move(velocity, -1.0)
	agent.update_facing()
	
	# Update sprite scale based on movement direction
	_update_sprite_scale(velocity)
	
	return RUNNING


## Updates sprite horizontal scale based on movement direction.
func _update_sprite_scale(velocity: Vector2) -> void:
	# Find sprite node (AnimatedSprite2D or Sprite2D)
	var sprite: Node2D = agent.get_node_or_null("AnimatedSprite2D")
	if not sprite:
		sprite = agent.get_node_or_null("Root/Rig/Sprite2D")
	if not sprite:
		sprite = agent.get_node_or_null("Sprite2D")
	
	if sprite:
		# Set scale.x to -1 when moving left, 1 when moving right
		if velocity.x < -0.1:
			sprite.scale.x = -1.0
		elif velocity.x > 0.1:
			sprite.scale.x = 1.0
		# If velocity.x is near 0, keep current scale
