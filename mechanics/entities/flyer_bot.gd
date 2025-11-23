class_name FlyerBot extends LivingEntity

@export var patrol_path : Path2D
@export var stats:LivingEntityData
var _path_points:PackedVector2Array=[]

@onready var awareness_progress_bar: ProgressBar = $Awareness
@onready var bt_player: BTPlayer = $BTPlayer

var blackboard : Blackboard

func _ready() -> void:
	# Get path points from patrol_path if it exists
	if patrol_path != null:
		_path_points = patrol_path.curve.get_baked_points()
		print(len(_path_points))
	
	blackboard = bt_player.get_blackboard()
	
	# Set waypoints to blackboard if we have path points
	#if not _path_points.is_empty():
		#set_waypoints_to_blackboard()


func _process(_delta: float) -> void:
	_update_awareness_bar()

func _physics_process(_delta: float) -> void:
	velocity = self_velocity + external_velocity
	move_and_slide()

func get_facing() -> float :
	if face_dir.x < 0:
		return -1
	else :
		return 1

func move(direction_or_velocity: Vector2, delta: float = -1.0) -> void:
	# If delta is provided (>= 0), this is the parent's move signature
	if delta >= 0.0:
		# Call parent's move function with direction and delta
		super.move(direction_or_velocity, delta)
		return
	
	var desired_velocity: Vector2 = direction_or_velocity
	self_velocity = desired_velocity

	if not desired_velocity.is_zero_approx():
		face_dir = desired_velocity.normalized()

	self.velocity = self_velocity + external_velocity


## Update facing direction based on current velocity.
## Expected by AI tasks.
func update_facing() -> void:
	if not self_velocity.is_zero_approx():
		face_dir = self_velocity.normalized()


## Sets all points from _path_points as waypoints on the blackboard.
func set_waypoints_to_blackboard() -> void:
	var waypoints: Array[Vector2] = []
	
	if patrol_path != null:
		for point in _path_points:
			var global_point: Vector2 = patrol_path.to_global(point)
			waypoints.append(global_point)
	else:
		for point in _path_points:
			waypoints.append(point)
	#blackboard.set_var(&"waypoints", waypoints)


## Updates the awareness progress bar from the blackboard.
func _update_awareness_bar() -> void:
	if not awareness_progress_bar:
		return
	
	var awareness: float = 0.0
	awareness = blackboard.get_var(&"awareness", 0.0, false)
	awareness_progress_bar.value = awareness
