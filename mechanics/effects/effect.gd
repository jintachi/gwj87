extends Node
class_name Effect

@export var priority : int = 0

# takes instance of entity specific data as input and modifies it
func compute(_data: Variant) -> void:
	pass

# same as on effect added
# func _enter_tree() -> void:
#	pass

# same as on effect removed
# func _exit_tree() -> void:
#	pass

# same as on effect process
# func _process(_delta: float) -> void:
#	pass
