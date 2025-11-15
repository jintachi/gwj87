extends CharacterBody2D
class_name Entity

signal effect_added
signal effect_removed

func add_effect(effect: Effect) -> void:
	add_child(effect)
	effect_added.emit(effect)

func remove_effect(effect: Effect) -> void:
	effect.queue_free()
	effect_removed.emit(effect)

func get_effects() -> Array:
	# node in group effects, that is not an effect, is an dev error, don't handle it!
	return get_tree().get_nodes_in_group(&"effects").map(func(node) -> Effect: return node)
