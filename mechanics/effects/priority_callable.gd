extends RefCounted
class_name PriorityCallable

var head : PriorityCallable
var tail : PriorityCallable

func get_priority() -> int: return 0
func bubble_up(data: Variant) -> void:
	if head:
		head.bubble_up(data)

func trickle_down(data: Variant) -> void:
	if tail:
		tail.trickle_down(data)
	else:
		bubble_up(data)

func remove() -> void:
	if head:
		head.tail = tail
