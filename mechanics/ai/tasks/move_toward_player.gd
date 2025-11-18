#*
#* move_toward_player.gd
#* =============================================================================
#* Alert Level 1: Caution - Moves slowly toward the player when visible.
#* =============================================================================
#*
@tool
extends BTAction
## Moves slowly (0.5x speed) toward player when visible. [br]
## Returns [code]RUNNING[/code] while moving. [br]
## Returns [code]SUCCESS[/code] if alert level != 1 (exits early).

## Blackboard variable for alert level (int).
@export var alert_level_var: StringName = &"alert_level"

## Blackboard variable for desired speed (float).
@export var speed_var: StringName = &"speed"

## Blackboard variable for player visibility (bool).
@export var player_visible_var: StringName = &"player_visible"

## Name of the SceneTree group containing the player.
@export var player_group: StringName = &"player"

## Target alert level required for this task (should be 1 for caution).
@export var required_alert_level: int = 1

## Speed multiplier for caution mode (0.5x).
@export var caution_speed_multiplier: float = 0.5

## How close to get to the player.
@export var arrival_tolerance: float = 50.0


func _generate_name() -> String:
	return "Move Toward Player"


func _enter() -> void:
	pass


func _tick(_delta: float) -> Status:
	# Check alert level first - must be at required level to continue
	var alert_level: int = 0
	if blackboard.has_var(alert_level_var):
		alert_level = blackboard.get_var(alert_level_var)
	
	if alert_level != required_alert_level:
		# Alert level changed, return SUCCESS immediately
		return SUCCESS
	
	# Check if player is visible
	var player_visible: bool = false
	if blackboard.has_var(player_visible_var):
		player_visible = blackboard.get_var(player_visible_var)
	
	if not player_visible:
		# Player not visible, stop
		agent.move(Vector2.ZERO)
		return RUNNING
	
	# Get player
	var players: Array[Node] = agent.get_tree().get_nodes_in_group(player_group)
	if players.is_empty():
		agent.move(Vector2.ZERO)
		return RUNNING
	
	var player: Node2D = players[0] as Node2D
	if not is_instance_valid(player):
		agent.move(Vector2.ZERO)
		return RUNNING
	
	# Move toward player
	var to_player: Vector2 = player.global_position - agent.global_position
	var distance: float = to_player.length()
	
	if distance < arrival_tolerance:
		# Close enough, stop
		agent.move(Vector2.ZERO)
		return RUNNING
	
	# Get speed and apply multiplier
	var speed: float = 200.0
	if blackboard.has_var(speed_var):
		speed = blackboard.get_var(speed_var)
	
	speed *= caution_speed_multiplier  # 0.5x speed
	
	var direction: Vector2 = to_player.normalized()
	var desired_velocity: Vector2 = direction * speed
	agent.move(desired_velocity)
	agent.update_facing()
	
	return RUNNING

