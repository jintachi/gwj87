extends InventoryItem
class_name RadChunkItem

@export var damage : float = 1.2
@export var hit_period = 0.2
var hit_timeout = 0.2
const RAD_CHUNK = preload("uid://cfb4u81tpku1j")

func item_added(new_inventory: InventorySlot, entity: Entity) -> void:
	super(new_inventory, entity)
	if entity is not Player: return
	var player = entity as Player
	player.extra_interactions.append(drop_rad)

func drop_rad(entity: Entity) -> void:
	inventorySlot.try_remove(self)
	var instance : Node2D = RAD_CHUNK.instantiate()
	entity.add_sibling(instance)
	instance.global_position = entity.global_position

func item_process(data: InventoryItem.ItemProcessData):
	hit_timeout -= data.delta
	while hit_timeout <= 0:
		hit_timeout += hit_period
		if data.entity is LivingEntity:
			var entity = data.entity as LivingEntity
			entity.take_damage(damage)
