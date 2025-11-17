extends LivingEntity
class_name Player

static var instance : Player

@export var general_inventory : Inventory

func _ready() -> void:
	super()
	instance = self
	
func get_attack_input() -> void:
	attack_dir = Input.get_vector("shoot_left", "shoot_right", "shoot_up", "shoot_down")
	
func process_items(delta: float) -> void:
	super(delta)
	var data = InventoryItem.ItemProcessData.new()
	data.entity = self
	data.delta = delta
	general_inventory.process_items(data)

func get_move_input() -> void:
	input_dir = Input.get_vector("left", "right", "up", "down")

func _process(delta: float) -> void:
	get_attack_input()
	process_items(delta)

func _physics_process(delta: float) -> void:
	get_move_input()
	move(input_dir, delta)
	move_and_collide(velocity * delta)
