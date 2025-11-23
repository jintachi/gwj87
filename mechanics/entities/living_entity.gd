extends Entity
class_name LivingEntity

signal sound
signal health_changed(new_health: float, max_health: float)

var input_dir : Vector2
var face_dir : Vector2
var attack_dir : Vector2

@export var health : float = 100.0
@export var data : LivingEntityData
var computed_data : LivingEntityData

@export var noise_level : float = 0.0
@export var self_velocity : Vector2
@export var external_velocity : Vector2

@export var head_item : InventorySlot
@export var weapon_item : InventorySlot
@export var armor_item : InventorySlot
@export var consumable_item : InventorySlot
@export var ammo_item : InventorySlot

func _ready() -> void:
	recompute_effects()
	health = computed_data.max_health
	head_item = head_item.duplicate(true)
	weapon_item = weapon_item.duplicate(true)
	armor_item = armor_item.duplicate(true)
	consumable_item = consumable_item.duplicate(true)
	ammo_item = ammo_item.duplicate(true)

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
		var entity : LivingEntity = vel_data.entity
		var direction : Vector2 = vel_data.direction
		var stats : LivingEntityData = vel_data.entity.computed_data
		var delta : float = vel_data.delta
		
		if not direction.is_zero_approx():
			entity.face_dir = direction
		entity.self_velocity = entity.self_velocity.move_toward(direction * stats.movement_speed, delta * stats.friction)
		
		#todo add acceleration curves
		
		entity.velocity = entity.self_velocity + entity.external_velocity

var process_velocity: VelocityCallable = VelocityCallable.new()

class SoundEvent:
	var position: Vector2
	var level: float

func move(direction: Vector2, delta: float) -> void:
	var vel_data = ProcessVelocityData.new()
	vel_data.entity = self
	vel_data.direction = direction
	vel_data.delta = delta
	process_velocity.trickle_down(vel_data)
	
	#var sound_event = SoundEvent.new()
	# sound...
	
	#sound.emit(sound_event)

func take_damage(damage: float) -> void:
	health_changed.emit(health - damage, computed_data.max_health)
	health -= damage
	if health <= 0:
		kill() 

func kill() -> void:
	queue_free()

func process_items(delta: float) -> void:
	var item_data = InventoryItem.ItemProcessData.new()
	item_data.entity = self
	item_data.delta = delta
	head_item.item_process(item_data)
	weapon_item.item_process(item_data)
	armor_item.item_process(item_data)
	consumable_item.item_process(item_data)
	ammo_item.item_process(item_data)
