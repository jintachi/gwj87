class_name Player extends LivingEntity

static var instance : Player
@onready var pickup_area: Area2D = $"Pickup Area"
var _footstep_timer: float = 0.0
var _footstep_interval: float = 0.5
var _current_speed: float = 0.0
@export var _footstep_volume: float = 25

var extra_interactions : Array[Callable]
@export var general_inventory : Inventory

@onready var animation: NomadAnimation = $AnimatedSprite2D
@onready var footsteps: AudioStreamPlayer2D = $Footsteps
var neutral_step_vol : float = 0.0
var loud_step_vol : float = 0.0
var quiet_step_vol : float = 0.0
@onready var radiation_display = $CanvasLayer/RadiationDisplay

@onready var radiation_detector = $RadiationDetector
var on_radiation_source
@export var radiation_rate : float = 0.08;
var current_radiation : float
var checkpoint_position
var _crouch_toggle:bool = false
@export var regen_multiplier = 4.0
@export var hit_period = 0.65
@export var radiation_tick_damage = 3.0
var hit_timer : Timer
var on_moving_platform : bool


func _ready() -> void:
	super()
	general_inventory = general_inventory.duplicate(true)
	instance = self
	pickup_area.body_entered.connect(item_in_range)
	pickup_area.body_exited.connect(item_out_of_range)
	
	# add footstep vol_db modifiers
	
	checkpoint_position = global_position
	health_changed.connect(
		func(current, max):
			radiation_display.update_health_display(health, computed_data.max_health)
	)
	radiation_detector.area_entered.connect(
		func(value):
			if !on_radiation_source:
				on_radiation_source = true
	)
	radiation_detector.area_exited.connect(
		func(value):
			if radiation_detector.get_overlapping_areas().is_empty():
				on_radiation_source = false
	)
	hit_timer = Timer.new()
	hit_timer.autostart = false
	hit_timer.one_shot = true
	hit_timer.wait_time = 1.0
	add_child(hit_timer)
	hit_timer.timeout.connect(
		func():
			health -= radiation_tick_damage
			health_changed.emit(health, computed_data.max_health)
			if health <= 0:
				self.kill() 
	)

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
	if not general_inventory.has_item(RadChunk) && current_radiation < 0.25 && health <= computed_data.max_health:
		health = minf(health + delta * regen_multiplier, computed_data.max_health)
		health_changed.emit(health, computed_data.max_health)
		if animation.radiation_amount > 0:
			animation.radiation_amount -= 0.02

func get_move_input() -> void:
	input_dir = Input.get_vector("left", "right", "up", "down")

func kill() -> void:
	#process_mode = Node.PROCESS_MODE_DISABLED
	if extra_interactions.size() > 0 :
		extra_interactions[0].call(self)
		var last_index = extra_interactions.size() - 1
		extra_interactions[0] = extra_interactions[last_index]
		extra_interactions.resize(last_index)
	health = computed_data.max_health
	health_changed.emit(health, health)
	TransitionScene.reload(checkpoint_position, self)
	for e in get_tree().get_nodes_in_group("enemies") :
		e.blackboard.set_var(&"awareness", 0.0)

func _handle_crouch_toggle() -> void:
	_crouch_toggle = not _crouch_toggle
	print(str(_crouch_toggle) +" crouch_toggle")

func _process(delta: float) -> void:
	#get_attack_input()
	process_items(delta)
	if Input.is_action_just_pressed("interact"):
		interact()
	if Input.is_action_just_pressed("pause"):
		pause_menu()
	if Input.is_action_just_pressed("crouch"): 
		_handle_crouch_toggle()
	if input_dir.is_zero_approx():
		if !_crouch_toggle :
			animation.animation = "idle"
		else :
			animation.animation = "crouch_idle"
	else:
		if input_dir.x < 0:
			animation.scale.x = -1
		else:
			animation.scale.x = 1
		if !_crouch_toggle :
			animation.animation = "walk"
		else : 
			animation.animation = "crouch_walk"

func _physics_process(delta: float) -> void:

	if on_radiation_source && current_radiation < 1:
		current_radiation = min(1.0, current_radiation + radiation_rate * delta)
		radiation_display.update_radiation_display(current_radiation)
	elif !on_radiation_source && current_radiation > 0:
		current_radiation = max(0.0, current_radiation - radiation_rate * 2.0 * delta)
		radiation_display.update_radiation_display(current_radiation)
	if hit_timer.is_stopped() and current_radiation >= 0.4:
		hit_timer.start()

	get_move_input()
	_handle_footsteps(delta)
	if _crouch_toggle : ## TRUE == Crouching
		move(input_dir/2, delta) ## half the vector
	else :
		move(input_dir, delta)
	move_and_slide()

@onready var pause_menu_ui: MarginContainer = $CanvasLayer/MarginContainer

func pause_menu() -> void:
	var is_paused = get_tree().paused
	if is_paused:
		# unpause
		get_tree().paused = false
		pause_menu_ui.visible = false
	else:
		get_tree().paused = true
		pause_menu_ui.visible = true
	pass

func _handle_footsteps(delta: float) -> void:
	_current_speed = velocity.length()

	if _current_speed > 10.0:  # Only emit sounds when moving
		# Adjust footstep interval based on speed
		if _current_speed > 150.0:  # Running
			_footstep_interval = 0.3
		elif _current_speed > 50.0:  # Walking
			_footstep_interval = 0.5
		else:  # Slow movement
			_footstep_interval = 0.8

		_footstep_timer += delta

		if _footstep_timer >= _footstep_interval:
			_footstep_timer = 0.0
			if _current_speed < 180.0 or _current_speed > 100:
				sound.emit(global_position,_footstep_volume)
				footsteps.volume_db = neutral_step_vol
			elif _current_speed >= 180:
				var loud_step = _footstep_volume * 1.5
				sound.emit(global_position,loud_step)
				footsteps.volume_db = loud_step_vol
			elif _current_speed <= 100:
				var quiet_step = _footstep_volume * .5
				sound.emit(global_position, quiet_step)
				footsteps.volume_db = quiet_step_vol
			# Emit footstep sound
			footsteps.play()
	else:
		_footstep_timer = 0.0
