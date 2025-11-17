extends Resource
class_name Effect

@export var priority : int = 0

# takes instance of entity specific data as input and modifies it
func compute(_data: Variant) -> void: pass
func add_effect(_node: Node) -> void: pass
func remove_effect(_node: Node) -> void: pass
func process_effect(_node: Node) -> void: pass
func physics_process_effect(_node: Node) -> void: pass
