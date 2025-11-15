extends Entity
class_name LivingEntity

signal onHit

@export var data : LivingEntityData
var computed_data : LivingEntityData

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

# TODO: It's not good
func hit(damage: float) -> void:
	onHit.emit(damage)
