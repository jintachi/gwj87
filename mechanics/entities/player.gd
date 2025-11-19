class_name Player extends LivingEntity

static var instance : Player
@onready var pickup_area: Area2D = $"Pickup Area"

var extra_interactions : Array[Callable]
@export var general_inventory : Inventory
@export var anim_sprite : AnimatedSprite2D

var _sound_events: Array[Dictionary] = []
var _footstep_timer: float = 0.0
var _footstep_interval: float = .5
var _step_volume: float = 20.0
var _crouch_toggle : bool = false


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
	var data = InventoryItem.ItemProcessData.new()
	data.entity = self
	data.delta = delta
	general_inventory.process_items(data)

func get_move_input() -> void:
	input_dir = Input.get_vector("left", "right", "up", "down")

func kill() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	TransitionScene.reload()

func _handle_crouch_toggle() -> void:
	if Input.is_action_just_pressed("crouch"):
		_crouch_toggle = not _crouch_toggle

func _process(delta: float) -> void:
	get_attack_input()
	process_items(delta)
	if Input.is_action_just_pressed("primary_action"):
		interact()

func _physics_process(delta: float) -> void:
	get_move_input()
	_handle_footsteps(delta)
	move(input_dir, delta)
	move_and_slide()
	_handle_crouch_toggle()

#func _physics_process(delta: float) -> void:
#	get_move_input()
#	_handle_movement(input_dir, delta)
#	move_and_slide()
		
func _handle_movement(input_dir:Vector2,delta: float) -> void:
	# Use input direction from arguments
	var input_vector := input_dir

	# Calculate desired velocity and accel
	var desired_velocity := input_vector * data.movement_speed
	
	if not _crouch_toggle :
		desired_velocity /= data.sneak_speed_multiplier
	
	var acceleration := data.movement_speed * delta
	
	# Apply acceleration or friction
	if input_vector.length() > 0.0:
		velocity = velocity.lerp(desired_velocity, acceleration * delta)
	else:
		velocity = velocity.lerp(Vector2.ZERO, data.friction * delta)
	
	_handle_footsteps(delta)

func _handle_footsteps(delta: float) -> void:
	var current_speed = data.movement_speed*velocity.length()*delta
	#$CurrentSpeed.text = str(round(current_speed))
	if current_speed > 15.0:  # Only emit sounds when moving
		# Adjust footstep interval based on speed
		if _crouch_toggle:
			anim_sprite.play("crouch_walk")
		else :
			anim_sprite.play("walk")
		if current_speed > 120.0:  # Running
			_footstep_interval = 0.3
		elif current_speed > 85.0:  # Walking
			_footstep_interval = 0.5
		else:  # Slow movement
			_footstep_interval = .8
			
		_footstep_timer += delta

		if _footstep_timer >= _footstep_interval:
			if current_speed<=80 :
				sound.emit(global_position, _step_volume)
				print("*step*")
				_footstep_timer = 0.0
			else:
				#volume *= 1.5  # Louder when running
				var loud_step := _step_volume*1.5
				sound.emit(global_position,loud_step)
				print("*STEP*")
				_footstep_timer = 0.0
	else:
		if _crouch_toggle:
			anim_sprite.play("crouch_idle")
		else :
			anim_sprite.play("idle")
		_footstep_timer = 0.0
