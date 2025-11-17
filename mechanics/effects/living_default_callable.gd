extends DefaultPriorityCallable
class_name LivingDefaultCallable

func get_priority() -> int: return 999999
func bubble_up(data: Variant) -> void:
	if data.preventDefault: return
	process(data)
	
func trickle_down(data: Variant) -> void:
	data.preventDefault = false
	super(data)

func process(_data: Variant) -> void:
	pass
