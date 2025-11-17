#*
#* patrol.gd
#* =============================================================================
#* Patrol task for stealth game enemies.
#* =============================================================================
#*
@tool
extends BTAction
## Moves the agent between waypoints in a patrol route. [br]
## Returns [code]RUNNING[/code] while moving to a waypoint. [br]
## Returns [code]SUCCESS[/code] when reaching a waypoint (waits briefly). [br]
## Returns [code]FAILURE[/code] if no waypoints are available.

## Blackboard variable that stores the array of waypoints (Array[Vector2]).
@export var waypoints_var: StringName = &"waypoints"

## Blackboard variable that stores the current waypoint index (int).
@export var current_waypoint_index_var: StringName = &"patrol_index"

## Blackboard variable that stores desired speed (float).
@export var speed_var: StringName = &"speed"

## Blackboard variable to store current state string.
@export var current_state_var: StringName = &"current_state"

## How close should the agent be to the waypoint to consider it reached.
@export var tolerance: float = 50.0

## How long to wait at each waypoint (in seconds).
@export var wait_time: float = 1.0

var _wait_timer: float = 0.0
var _is_waiting: bool = false


func _generate_name() -> String:
	return "Patrol  waypoints: %s" % [LimboUtility.decorate_var(waypoints_var)]


func _enter() -> void:
	_wait_timer = 0.0
	_is_waiting = false
	_update_state("Patrolling")
	print("Patrol task: ENTERED - Starting patrol behavior")


func _tick(_delta: float) -> Status:
	# Debug: Verify task is being ticked
	if not has_meta("tick_count"):
		set_meta("tick_count", 0)
	var tick_count: int = get_meta("tick_count")
	tick_count += 1
	set_meta("tick_count", tick_count)
	if tick_count <= 20 or tick_count % 60 == 0:
		print("Patrol: _tick() #%d" % tick_count)
	
	var waypoints: Array = []
	if blackboard.has_var(waypoints_var):
		waypoints = blackboard.get_var(waypoints_var)
	
	if waypoints.is_empty():
		print("Patrol: No waypoints in blackboard!")
		return FAILURE
	
	# Initialize patrol index if not set
	if not blackboard.has_var(current_waypoint_index_var):
		blackboard.set_var(current_waypoint_index_var, 0)
	
	var current_index: int = 0
	if blackboard.has_var(current_waypoint_index_var):
		current_index = blackboard.get_var(current_waypoint_index_var)
	
	# Ensure index is valid
	if current_index < 0 or current_index >= waypoints.size():
		current_index = 0
		blackboard.set_var(current_waypoint_index_var, 0)
	
	var target_waypoint: Vector2 = waypoints[current_index]
	var distance_to_waypoint: float = agent.global_position.distance_to(target_waypoint)
	
	# If we're waiting at a waypoint
	if _is_waiting:
		_wait_timer += _delta
		if _wait_timer >= wait_time:
			# Move to next waypoint
			current_index = (current_index + 1) % waypoints.size()
			blackboard.set_var(current_waypoint_index_var, current_index)
			_is_waiting = false
			_wait_timer = 0.0
		return RUNNING
	
	# Check if we've reached the waypoint
	if distance_to_waypoint < tolerance:
		_is_waiting = true
		_wait_timer = 0.0
		return RUNNING
	
	# Check alert level - if >= 1, don't patrol (cautious/investigate/engaged instead)
	# Note: This should not run at alert level >= 1 due to selector, but check anyway
	var alert_level: int = 0
	if blackboard.has_var(&"alert_level"):
		alert_level = blackboard.get_var(&"alert_level")

	if alert_level >= 1:
		# NPC is in cautious/investigating/engaged state, don't patrol
		# Return SUCCESS immediately (task completes, doesn't interfere)
		# Don't set movement - higher alert level tasks should be handling movement
		if tick_count <= 20 or tick_count % 60 == 0:
			print("Patrol: Alert level %d >= 1, returning SUCCESS (exiting, higher alert level tasks handle movement)" % alert_level)
		# Return SUCCESS so task exits - higher alert level tasks will handle movement
		return SUCCESS

	# Check if NPC is detecting - if so, don't move (detection task handles stopping)
	var is_detecting: bool = false
	if blackboard.has_var(&"is_detecting"):
		is_detecting = blackboard.get_var(&"is_detecting")

	if is_detecting:
		# NPC is detecting player, don't move (detection task handles stopping)
		_update_state("Detecting player - paused patrol")
		return RUNNING
	
	# Move towards the waypoint
	var speed: float = 200.0
	if blackboard.has_var(speed_var):
		speed = blackboard.get_var(speed_var)
	var direction: Vector2 = agent.global_position.direction_to(target_waypoint)
	var desired_velocity: Vector2 = direction * speed
	agent.move(desired_velocity)
	agent.update_facing()
	
	_update_state("Patrolling to waypoint %d/%d" % [current_index + 1, waypoints.size()])
	
	return RUNNING


func _update_state(state: String) -> void:
	if not current_state_var.is_empty():
		blackboard.set_var(current_state_var, state)
