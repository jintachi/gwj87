#*
#* detect_sight.gd
#* =============================================================================
#* Sight detection - checks if player is visible and increases awareness.
#* =============================================================================
#*
@tool
extends BTAction
## Checks if player is visible through sight. [br]
## Sets blackboard variables for sight detection status. [br]
## Returns [code]RUNNING[/code] always (doesn't block sequence).

## Name of the SceneTree group containing the player.
@export var player_group: StringName = &"player"

## Maximum vision range.
@export var vision_range: float = 400.0

## Vision cone angle in degrees (half-angle from forward direction).
@export var vision_angle: float = 60.0

## Collision layers to check for obstacles (line of sight).
@export var obstacle_layers: int = 1

## Blackboard variable to store if player is visible (bool).
@export var player_visible_var: StringName = &"player_visible"

## Blackboard variable to store last sight time (float, seconds since last sight).
@export var last_sight_time_var: StringName = &"last_sight_time"

## Blackboard variable to store player position when last seen (Vector2).
@export var last_sight_position_var: StringName = &"last_sight_position"

## Blackboard variable to store awareness (float, 0-300).
@export var awareness_var: StringName = &"awareness"


## Awareness increase amount when player is visible.
@export var awareness_increase_amount: float = 10.0

## Cooldown time in seconds between awareness increases from sight.
@export var sight_cooldown_time: float = 0.2


func _generate_name() -> String:
	return "Detect Sight  range: %.0f, angle: %.0f°" % [vision_range, vision_angle]


func _enter() -> void:
	# Initialize blackboard variables
	if not blackboard.has_var(player_visible_var):
		blackboard.set_var(player_visible_var, false)
	if not blackboard.has_var(last_sight_time_var):
		blackboard.set_var(last_sight_time_var, 0.0)
	if not blackboard.has_var(last_sight_position_var):
		blackboard.set_var(last_sight_position_var, Vector2.ZERO)


func _tick(delta: float) -> Status:
	var players: Array[Node] = agent.get_tree().get_nodes_in_group(player_group)
	
	var sight_position: Vector2 = Vector2.ZERO
	
	if players.is_empty():
		blackboard.set_var(player_visible_var, false)
		_handle_not_visible(delta)
		return RUNNING
	
	var player: Node2D = players[0] as Node2D
	if not is_instance_valid(player):
		blackboard.set_var(player_visible_var, false)
		_handle_not_visible(delta)
		return RUNNING
	
	var to_player: Vector2 = player.global_position - agent.global_position
	var distance: float = to_player.length()
	
	# Check range
	if distance > vision_range:
		blackboard.set_var(player_visible_var, false)
		_handle_not_visible(delta)
		return RUNNING
	
	# Check vision cone
	var forward: Vector2
	if agent.has_method("get_facing_direction"):
		forward = agent.get_facing_direction()
		if forward.length() < 0.1:
			forward = Vector2.RIGHT
	else:
		var facing: float = 1.0
		if agent.has_method("get_facing"):
			facing = agent.get_facing()
		forward = Vector2.RIGHT * facing
	
	var to_player_normalized: Vector2 = to_player.normalized()
	var angle_to_player: float = rad_to_deg(forward.angle_to(to_player_normalized))
	
	if abs(angle_to_player) > vision_angle:
		blackboard.set_var(player_visible_var, false)
		_handle_not_visible(delta)
		return RUNNING
	
	# Check line of sight
	var space_state = agent.get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(
		agent.global_position,
		player.global_position
	)
	query.collision_mask = obstacle_layers
	query.exclude = [agent.get_rid()]
	if player is CharacterBody2D or player is RigidBody2D or player is Area2D:
		query.exclude.append(player.get_rid())
	
	var result = space_state.intersect_ray(query)
	
	if not result.is_empty():
		var collider = result.get("collider", null)
		# If we hit the player, line of sight is clear (shouldn't happen with exclude, but check anyway)
		if collider == player:
			# Line of sight is clear, continue to visibility check
			pass
		else:
			# Line of sight is blocked by something else
			blackboard.set_var(player_visible_var, false)
			_handle_not_visible(delta)
			return RUNNING
	
	# Player is visible!
	sight_position = player.global_position
	
	blackboard.set_var(player_visible_var, true)
	blackboard.set_var(last_sight_time_var, 0.0)
	blackboard.set_var(last_sight_position_var, sight_position)
	
	var awareness: float = 0.0
	if blackboard.has_var(awareness_var):
		awareness = blackboard.get_var(awareness_var)
	
	awareness += awareness_increase_amount
	awareness = min(awareness, 300.0)  # Cap at 300
	blackboard.set_var(awareness_var, awareness)
	
	# Return RUNNING to keep detection active continuously
	return RUNNING


func _handle_not_visible(delta: float) -> void:
	# Increment time since last sight
	var last_sight_time: float = 0.0
	if blackboard.has_var(last_sight_time_var):
		last_sight_time = blackboard.get_var(last_sight_time_var)
	blackboard.set_var(last_sight_time_var, last_sight_time + delta)
