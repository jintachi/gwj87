#*
#* look_toward_player.gd
#* =============================================================================
#* Alert Level 1: Caution - Faces the direction of the player when visible.
#* =============================================================================
#*
@tool
extends BTAction
## Faces the direction of player when visible. [br]
## Returns [code]RUNNING[/code] while in caution state. [br]
## Returns [code]SUCCESS[/code] if alert level != 1 (exits early).

## Blackboard variable for alert level (int).
@export var alert_level_var: StringName = &"alert_level"

## Blackboard variable for player visibility (bool).
@export var player_visible_var: StringName = &"player_visible"

## Name of the SceneTree group containing the player.
@export var player_group: StringName = &"player"

## Target alert level required for this task (should be 1 for caution).
@export var required_alert_level: int = 1


func _generate_name() -> String:
	return "Look Toward Player"


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
	
	if player_visible:
		# Get player
		var players: Array[Node] = agent.get_tree().get_nodes_in_group(player_group)
		if not players.is_empty():
			var player: Node2D = players[0] as Node2D
			if is_instance_valid(player):
				# Face direction of player
				var to_player: Vector2 = player.global_position - agent.global_position
				var direction: Vector2 = to_player.normalized()
				if agent.has_method("face_dir"):
					agent.face_dir(direction)
	
	return RUNNING

