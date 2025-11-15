extends LivingEntity
class_name Player

func get_input():
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = input_dir * computed_data.movement_speed

func _physics_process(delta):
	get_input()
	move_and_collide(velocity * delta)
