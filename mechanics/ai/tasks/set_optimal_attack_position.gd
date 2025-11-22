#*
#* set_optimal_attack_position.gd
#* =============================================================================
#* Sets the optimal attack position - closest position in radius from player.
#* =============================================================================
#*
@tool
extends BTAction
## Sets the optimal attack position as the closest point in a radius from player. [br]
## Returns [code]SUCCESS[/code] when position is set.

## Name of the SceneTree group containing the player.
@export var player_group: StringName = &"player"

@export var attack_radius: float = 180.0

## Blackboard variable for target position (Vector2).
@export var target_position_var: StringName = &"target_position"


func _generate_name() -> String:
	return "Set Optimal Attack Position (%.0fpx)" % attack_radius


func _enter() -> void:
	pass


func _tick(_delta: float) -> Status:
	var player_pos: Vector2 = Player.instance.global_position
	var agent_pos: Vector2 = agent.global_position
	var to_agent: Vector2 = (agent_pos - player_pos).normalized()
	
	# Calculate optimal position: player position + direction * radius
	# This is the closest point in the radius from the player's perspective
	# The agent will move towards this position
	var optimal_pos: Vector2 = player_pos + (to_agent * attack_radius)
	
	# Set target position in blackboard
	blackboard.set_var(target_position_var, optimal_pos)
	
	return SUCCESS
