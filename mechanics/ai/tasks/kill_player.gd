#*
#* kill_player.gd
#* =============================================================================
#* Kills the player by calling their kill function.
#* =============================================================================
#*
@tool
extends BTAction
## Kills the player by calling their kill function. [br]
## Returns [code]SUCCESS[/code] after calling kill.

## Name of the SceneTree group containing the player.
@export var player_group: StringName = &"player"


func _generate_name() -> String:
	return "Kill Player"


func _enter() -> void:
	pass


func _tick(_delta: float) -> Status:
	# Try to get player via static instance first
	var player: Player = Player.instance
	
	# Fallback to finding player in tree if instance is not available
	if not is_instance_valid(player):
		var players: Array[Node] = agent.get_tree().get_nodes_in_group(player_group)
		if not players.is_empty() and players[0] is Player:
			player = players[0] as Player
	
	# Call kill function if player is valid
	if is_instance_valid(player):
		player.kill()
		return SUCCESS
	
	# Player not found
	push_warning("Kill Player: Player not found")
	return FAILURE
