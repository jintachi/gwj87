extends InventoryItem
class_name TestShooter

var attacking : bool
@export var bullet : PackedScene

func item_process(_item_process_data: ItemProcessData) -> void:
	if _item_process_data.entity is not LivingEntity: return
	var living_entity : LivingEntity = _item_process_data.entity
	if living_entity.attack_dir.is_zero_approx() or attacking: return
	attacking = true
	var direction = living_entity.attack_dir
	
	var instance = bullet.instantiate()
	living_entity.add_child(instance)
	
	if instance is RigidBody2D:
		var rb = instance as RigidBody2D
		rb.add_constant_force(direction * 100)
	
	await living_entity.get_tree().create_timer(5.0).timeout
	
	if instance:
		instance.queue_free()
		
	attacking = false
