extends Entity
class_name LivingEntity

var input_dir : Vector2
var attack_dir : Vector2

@export var data : LivingEntityData
var computed_data : LivingEntityData

@export var head_item : InventorySlot
@export var weapon_item : InventorySlot
@export var armor_item : InventorySlot
@export var consumable_item : InventorySlot
@export var ammo_item : InventorySlot

func _ready() -> void:
	recompute_effects()

func recompute_effects() -> void:
	computed_data = data.duplicate(true)
	for effect in effects:
		effect.compute(computed_data)

class ProcessVelocityData:
	var preventDefault: bool
	var entity: LivingEntity
	var direction: Vector2
	var delta: float

class VelocityCallable extends LivingDefaultCallable:
	func process(data: Variant) -> void:
		var vel_data = data as ProcessVelocityData
		vel_data.entity.velocity = vel_data.direction * vel_data.entity.computed_data.movement_speed

var process_velocity: VelocityCallable = VelocityCallable.new()

func move(direction: Vector2, delta: float) -> void:
	var vel_data = ProcessVelocityData.new()
	vel_data.entity = self
	vel_data.direction = direction
	vel_data.delta = delta
	process_velocity.trickle_down(vel_data)

func process_items(delta: float) -> void:
	var item_data = InventoryItem.ItemProcessData.new()
	item_data.entity = self
	item_data.delta = delta
	head_item.item_process(item_data)
	weapon_item.item_process(item_data)
	armor_item.item_process(item_data)
	consumable_item.item_process(item_data)
	ammo_item.item_process(item_data)
