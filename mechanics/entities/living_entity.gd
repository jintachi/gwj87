extends Entity
class_name LivingEntity

signal onHit

@export var data : LivingEntityData
var computed_data : LivingEntityData

func _ready() -> void:
	recompute_effects()

func recompute_effects() -> void:
	computed_data = data.duplicate(true)
	for effect in get_effects():
		effect.compute(computed_data)

# TODO: It's not good
func hit(damage: float) -> void:
	onHit.emit(damage)
