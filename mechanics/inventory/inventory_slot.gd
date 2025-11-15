extends Resource
class_name InventorySlot
enum Type { Any, Headpiece, Chestplate, Consumable, Ammo, Weapon }

signal item_added
signal item_removed

@export var slot_type : Type = Type.Any
@export var item : InventoryItem

func try_add(new_item: InventoryItem) -> bool:
	if slot_type != Type.Any and slot_type != new_item.slot_type: return false
	if item != null: return false
	item_added.emit(new_item)
	new_item.item_added(self)
	return true

func try_remove(item_spec: InventoryItem) -> bool:
	if item != item_spec: return false
	item_removed.emit(item_spec)
	item.item_removed()
	item = null
	return true

func item_process(item_process_data: InventoryItem.ItemProcessData) -> void:
	if item:
		item.item_process(item_process_data)
