extends LivingEntity
class_name Player

static var instance : Player
var _sound_events: Array[Dictionary] = []
var _footstep_timer: float = 0.0
var _footstep_interval: float = 0.5

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
	# _update_noise_level() # todo: change sound system
	_handle_footsteps(delta)
	move(input_dir, delta)
	move_and_collide(velocity * delta)

func _handle_footsteps(delta: float) -> void:
	var current_speed := velocity.length()

	if current_speed > 10.0:  # Only emit sounds when moving
		# Adjust footstep interval based on speed
		if current_speed > 150.0:  # Running
			_footstep_interval = 0.3
		elif current_speed > 50.0:  # Walking
			_footstep_interval = 0.5
		else:  # Slow movement
			_footstep_interval = 0.8

		_footstep_timer += delta

		if _footstep_timer >= _footstep_interval:
			_footstep_timer = 0.0
			# Emit footstep sound
			if current_speed > 150.0:
				#volume *= 1.5  # Louder when running
				#todo emit sound
				pass
	else:
		_footstep_timer = 0.0
