#*
#* get_first_in_group.gd
#* =============================================================================
#* Gets the first node from a SceneTree group and stores it in the blackboard.
#* =============================================================================
#*
@tool
extends BTAction
## Gets the first node from a specified group and stores it as the target. [br]
## Returns [code]SUCCESS[/code] if a node is found. [br]
## Returns [code]FAILURE[/code] if the group is empty or node is invalid.

## Name of the SceneTree group to search.
@export var group: StringName = &"player"

## Blackboard variable to store the target node.
@export var target_var: StringName = &"target"


func _generate_name() -> String:
	return "Get First in Group: %s" % group


func _tick(_delta: float) -> Status:
	var nodes: Array[Node] = agent.get_tree().get_nodes_in_group(group)
	
	if nodes.is_empty():
		return FAILURE
	
	var target: Node = nodes[0]
	if not is_instance_valid(target):
		return FAILURE
	
	blackboard.set_var(target_var, target)
	return SUCCESS

