extends Effect

var parentEntity : Entity

class IceModifier extends PriorityCallable:
	func get_priority() -> int: return 1
	func bubble_up(data: Variant) -> void:
		var vel_data : LivingEntity.ProcessVelocityData = data as LivingEntity.ProcessVelocityData
		data.preventDefault = true
		
		vel_data.entity.velocity = vel_data.entity.velocity.normalized().move_toward(vel_data.direction, vel_data.delta) * vel_data.entity.computed_data.movement_speed
		super(data)
var IceModifierInstance = IceModifier.new()

func _enter_tree() -> void:
	parentEntity = get_parent() as Entity
	if parentEntity is LivingEntity:
		parentEntity.process_velocity.add_front_sorted(IceModifierInstance)

func _exit_tree() -> void:
	IceModifierInstance.remove()
	IceModifierInstance = null
