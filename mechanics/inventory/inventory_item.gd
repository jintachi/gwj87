extends Resource
class_name InventoryItem

# this would cause recursion in inspector
var inventorySlot : InventorySlot
@export var name : String = "New Item"
@export var description : String = "..."
@export var icon : Texture2D
@export var slot_type : InventorySlot.Type

func item_added(new_inventory: InventorySlot, entity: Entity) -> void:
	inventorySlot = new_inventory
	
func item_removed() -> void:
	inventorySlot = null

class ItemProcessData:
	var entity: Entity
	var delta: float

func item_process(_item_process_data: ItemProcessData) -> void: pass
