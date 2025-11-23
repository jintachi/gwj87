extends RefCounted
class_name ArrEx

static func get_or(array: Array, index: int, default: Variant) -> Variant: 
	return array[index] if len(array) > index else default
