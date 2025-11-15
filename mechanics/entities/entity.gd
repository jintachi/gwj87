extends CharacterBody2D
class_name Entity

func get_effects() -> Array:
	# node in group effect, that is not an effect, is an dev error, don't handle it!
	return get_tree().get_nodes_in_group(&"effect").map(func(node) -> Effect: return node as Effect)
