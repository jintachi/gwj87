extends Resource
class_name Inventory

@export var item_slots : Array[InventorySlot]
@export var size : int = 1

func try_add(item: InventoryItem, entity: Entity = null) -> bool:
	for slot in item_slots:
		if slot.try_add(item, entity):
			return true
	return false

func process_items(item_process_data: InventoryItem.ItemProcessData) -> void:
	for item_slot in item_slots:
		if item_slot.item:
			item_slot.item.item_process(item_process_data)

func has_free_slot(item: InventoryItem) -> bool:
	for slot in item_slots:
		if slot.can_accept(item):
			return true
	return false
