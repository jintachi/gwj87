extends LivingEntity
class_name Player

static var instance : Player
var input_dir : Vector2
var attack_dir : Vector2

func _ready() -> void:
	super()
	instance = self
	
func get_attack_input() -> void:
	attack_dir = Input.get_vector("attack_left", "attack_right", "attack_up", "attack_down")
func get_move_input() -> void:
	input_dir = Input.get_vector("left", "right", "up", "down")

func _physics_process(delta: float) -> void:
	get_move_input()
	move(input_dir, delta)
	move_and_collide(velocity * delta)
