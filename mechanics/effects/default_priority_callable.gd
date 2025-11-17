extends PriorityCallable
class_name DefaultPriorityCallable

func add_front_sorted(element: PriorityCallable) -> void:
	# first priority callable should be default
	# it is assumed it's called on that default behavior, and it's not sorted
	
	var tested_element = self
	var priority = element.get_priority()
	while tested_element.tail and tested_element.get_priority() <= priority:
		tested_element = tested_element.tail
	
	# now new element's priority is greater than tested element
	element.tail = tested_element.tail
	element.head = tested_element
	tested_element.tail = element
	# tested tail remains the same
