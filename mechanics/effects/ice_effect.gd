extends Effect
class_name IceEffect

var parentEntity : Entity

class IceModifier extends PriorityCallable:
	var last_direction : Vector2
	func get_priority() -> int: return 1
	func bubble_up(data: Variant) -> void:
		var vel_data : LivingEntity.ProcessVelocityData = data as LivingEntity.ProcessVelocityData
		data.preventDefault = true
		if !vel_data.direction.is_zero_approx():
			last_direction = vel_data.direction
		vel_data.entity.velocity = vel_data.entity.velocity.normalized().move_toward(last_direction, vel_data.delta * vel_data.entity.computed_data.movement_speed / 60) * vel_data.entity.computed_data.movement_speed
		super(data)

var IceModifierInstance = IceModifier.new()

func add_effect(node: Node) -> void:
	parentEntity = node as Entity
	if parentEntity is LivingEntity:
		parentEntity.process_velocity.add_front_sorted(IceModifierInstance)

func remove_effect(_node: Node) -> void:
	IceModifierInstance.remove()
	IceModifierInstance = null
