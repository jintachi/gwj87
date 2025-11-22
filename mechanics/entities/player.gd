extends LivingEntity
class_name Player

static var instance : Player
@onready var pickup_area: Area2D = $"Pickup Area"
var _footstep_timer: float = 0.0
var _footstep_interval: float = 0.5

var extra_interactions : Array[Callable]
@export var general_inventory : Inventory

@onready var animation: NomadAnimation = $AnimatedSprite2D
@onready var footsteps: AudioStreamPlayer2D = $Footsteps


func _ready() -> void:
	super()
	general_inventory = general_inventory.duplicate(true)
	instance = self
	pickup_area.body_entered.connect(item_in_range)
	pickup_area.body_exited.connect(item_out_of_range)

func item_in_range(body: Node2D) -> void:
	if body is PhysicalItem:
		body.item_in_range(self)

func item_out_of_range(body: Node2D) -> void:
	if body is PhysicalItem:
		body.item_out_of_range(self)

func interact() -> void:
	var items_in_range : Array[Node2D] = pickup_area.get_overlapping_bodies()
	if len(items_in_range) > 0:
		if items_in_range[0] is PhysicalItem:
			(items_in_range[0] as PhysicalItem).pick_up(self)
	elif len(extra_interactions) > 0:
		extra_interactions[0].call(self)
		
		var last_index = extra_interactions.size() - 1
		extra_interactions[0] = extra_interactions[last_index]
		extra_interactions.resize(last_index)

func get_attack_input() -> void:
	attack_dir = Input.get_vector("shoot_left", "shoot_right", "shoot_up", "shoot_down")
	
func process_items(delta: float) -> void:
	super(delta)
	var item_data = InventoryItem.ItemProcessData.new()
	item_data.entity = self
	item_data.delta = delta
	general_inventory.process_items(item_data)
	if not general_inventory.has_item(RadChunk):
		health = minf(health + delta, computed_data.max_health)
		if animation.radiation_amount > 0:
			animation.radiation_amount -= 0.02

func get_move_input() -> void:
	input_dir = Input.get_vector("left", "right", "up", "down")

func kill() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	TransitionScene.reload()

func _process(delta: float) -> void:
	#get_attack_input()
	process_items(delta)
	if Input.is_action_just_pressed("interact"):
		interact()
	if input_dir.is_zero_approx():
		animation.animation = "idle"
	else:
		animation.animation = "walk"

func _physics_process(delta: float) -> void:
	get_move_input()
	_handle_footsteps(delta)
	move(input_dir, delta)
	move_and_slide()

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
			footsteps.play()
			# Emit footstep sound
			if current_speed > 150.0:
				#volume *= 1.5  # Louder when running
				#todo emit sound
				pass
	else:
		_footstep_timer = 0.0
