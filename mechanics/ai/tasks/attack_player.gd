#*
#* attack_player.gd
#* =============================================================================
#* Attack task for flyer bot - performs attack action on player.
#* =============================================================================
#*
@tool
extends BTAction
## Attacks the player. [br]
## Returns [code]RUNNING[/code] while attacking. [br]
## Returns [code]SUCCESS[/code] when attack completes.

## Name of the SceneTree group containing the player.
@export var player_group: StringName = &"player"

## Blackboard variable for lock-on timer (float).
@export var lock_on_timer_var: StringName = &"lock_on_timer"


func _generate_name() -> String:
	return "Attack Player"


func _enter() -> void:
	pass


func _tick(_delta: float) -> Status:
	# Check if lock-on timer has completed
	var timer: float = 1.0  # Default to not ready
	if blackboard.has_var(lock_on_timer_var):
		timer = blackboard.get_var(lock_on_timer_var)
	
	# Only attack if lock-on is complete
	if timer > 0.0:
		return RUNNING
	
	# Find player
	var players: Array[Node] = agent.get_tree().get_nodes_in_group(player_group)
	if players.is_empty():
		return FAILURE
	
	var player: Node2D = players[0] as Node2D
	if not is_instance_valid(player):
		return FAILURE
	
	# Perform attack (placeholder - implement actual attack logic here)
	# For now, just return SUCCESS to indicate attack was performed
	_do_attack(player)
	
	return SUCCESS


func _do_attack(target: Node2D) -> void:
	# Placeholder for actual attack implementation
	# This should trigger attack animations, spawn projectiles, etc.
	print("FlyerBot attacking player at: ", target.global_position)
