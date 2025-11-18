#*
#* stealth_enemy.gd
#* =============================================================================
#* Stealth enemy script with patrol waypoint generation.
#* =============================================================================
#*
extends "res://mechanics/agents/agent_base.gd"

## Maximum radius from spawn position to generate patrol waypoints.
@export var patrol_radius: float = 300.0

## Number of waypoints to generate from tilemap.
@export var waypoint_count: int = 6

## Minimum distance between waypoints.
@export var min_waypoint_distance: float = 80.0

## TileMap to scan for walkable areas (optional).
@export var tilemap: TileMap

## Path2D to follow for patrol (optional, takes priority over tilemap generation).
@export var patrol_path: Path2D

## Spawn position (used as center for patrol radius).
var spawn_position: Vector2

@onready var bt_player: BTPlayer = $BTPlayer
@onready var current_state_label: Label = $CurrentState
@onready var awareness_progress_bar: ProgressBar = $Awareness

var _debug_tick_count: int = 0


func _ready() -> void:
	super._ready()
	spawn_position = global_position
	
	# Wait a frame to ensure BTPlayer is ready
	await get_tree().process_frame
	
	# Verify BTPlayer is set up correctly
	if not bt_player:
		push_error("Stealth Enemy: BTPlayer node not found!")
		return
	
	print("Stealth Enemy: BTPlayer found, checking configuration...")
	if not bt_player.behavior_tree:
		push_error("Stealth Enemy: Behavior tree not assigned to BTPlayer!")
	else:
		print("Stealth Enemy: Behavior tree assigned: %s" % bt_player.behavior_tree.resource_path)
	
	var blackboard = bt_player.get_blackboard()
	if not blackboard:
		push_error("Stealth Enemy: Blackboard not found!")
	else:
		print("Stealth Enemy: Blackboard found")
	
	# Test: Check if player can be found
	var players = get_tree().get_nodes_in_group("player")
	print("Stealth Enemy: Found %d players in 'player' group" % players.size())
	if not players.is_empty():
		var player = players[0]
		var distance = global_position.distance_to(player.global_position)
		print("Stealth Enemy: Player at distance %.0f, position %s, enemy at %s" % [distance, player.global_position, global_position])
	else:
		push_error("Stealth Enemy: No players found in 'player' group!")
	
	# If patrol_path is set, use it
	if patrol_path:
		set_patrol_from_path(patrol_path)
	# Otherwise, try to generate from tilemap
	elif tilemap:
		generate_patrol_from_tilemap()
	# Otherwise, use default waypoints from blackboard
	
	# Start updating UI labels
	_update_labels()


func _process(_delta: float) -> void:
	_update_labels()
	
	# Debug: Check if BTPlayer is running
	_debug_tick_count += 1
	if _debug_tick_count % 300 == 0:  # Every 5 seconds at 60fps
		if bt_player:
			print("Stealth Enemy: BTPlayer exists, checking behavior tree...")
			var blackboard = bt_player.get_blackboard()
			if blackboard:
				print("  - Blackboard exists")
				var alert_level: int = 0
				if blackboard.has_var(&"alert_level"):
					alert_level = blackboard.get_var(&"alert_level")
				var player_visible: bool = false
				if blackboard.has_var(&"player_visible"):
					player_visible = blackboard.get_var(&"player_visible")
				var player_audible: bool = false
				if blackboard.has_var(&"player_audible"):
					player_audible = blackboard.get_var(&"player_audible")
				print("  - Alert Level: %d" % alert_level)
				print("  - Player Visible: %s" % player_visible)
				print("  - Player Audible: %s" % player_audible)
			else:
				print("  - ERROR: Blackboard is null!")
		else:
			print("Stealth Enemy: ERROR - BTPlayer is null!")


## Sets patrol waypoints from a Path2D.
func set_patrol_from_path(path: Path2D) -> void:
	if not is_instance_valid(path):
		push_error("Invalid Path2D provided to set_patrol_from_path")
		return
	
	var curve: Curve2D = path.curve
	if not curve:
		push_error("Path2D has no curve")
		return
	
	var waypoints: Array[Vector2] = []
	
	# Sample points along the path
	var sample_count: int = max(4, waypoint_count)
	var path_length: float = curve.get_baked_length()
	
	for i in range(sample_count):
		var offset: float = (i / float(sample_count - 1)) * path_length
		var point: Vector2 = curve.sample_baked(offset)
		
		# Convert to global position if path is not a parent
		if path.get_parent():
			point = path.to_global(point)
		else:
			point = path.global_position + point
		
		waypoints.append(point)
	
	_set_waypoints(waypoints)


## Generates patrol waypoints by scanning a tilemap within patrol radius.
func generate_patrol_from_tilemap() -> void:
	if not is_instance_valid(tilemap):
		push_error("Invalid TileMap provided to generate_patrol_from_tilemap")
		return
	
	var waypoints: Array[Vector2] = []
	
	# Get tilemap bounds within patrol radius
	var map_rect: Rect2 = tilemap.get_used_rect()
	var local_spawn: Vector2 = tilemap.to_local(spawn_position)
	
	# Find walkable tiles within radius
	var walkable_tiles: Array[Vector2] = []
	
	for x in range(map_rect.position.x, map_rect.position.x + map_rect.size.x):
		for y in range(map_rect.position.y, map_rect.position.y + map_rect.size.y):
			var tile_pos: Vector2 = Vector2(x, y)
			var world_pos: Vector2 = tilemap.map_to_local(tile_pos)
			
			# Check if within patrol radius
			if world_pos.distance_to(local_spawn) > patrol_radius:
				continue
			
			# Check if tile exists and is walkable (has a tile at this position)
			var source_id: int = tilemap.get_cell_source_id(0, tile_pos)
			if source_id == -1:  # No tile
				continue
			
			# Check if position is valid (not blocked by obstacles)
			var global_tile_pos: Vector2 = tilemap.to_global(world_pos)
			if _is_walkable_position(global_tile_pos):
				walkable_tiles.append(global_tile_pos)
	
	# Select waypoints from walkable tiles
	if walkable_tiles.is_empty():
		push_warning("No walkable tiles found within patrol radius")
		# Fallback to simple circular pattern
		_generate_fallback_waypoints()
		return
	
	# Use a simple selection algorithm: pick points that are spread out
	waypoints.append(spawn_position)  # Always start at spawn
	
	var remaining_tiles: Array = walkable_tiles.duplicate()
	var last_waypoint: Vector2 = spawn_position
	
	for i in range(waypoint_count - 1):
		if remaining_tiles.is_empty():
			break
		
		# Find the tile furthest from the last waypoint
		var best_tile: Vector2
		var best_distance: float = 0.0
		var best_index: int = -1
		
		for j in range(remaining_tiles.size()):
			var tile: Vector2 = remaining_tiles[j]
			var distance: float = tile.distance_to(last_waypoint)
			
			if distance >= min_waypoint_distance and distance > best_distance:
				best_distance = distance
				best_tile = tile
				best_index = j
		
		if best_index >= 0:
			waypoints.append(best_tile)
			remaining_tiles.remove_at(best_index)
			last_waypoint = best_tile
		else:
			# If no tile is far enough, pick the closest one that's at least min_waypoint_distance away
			for j in range(remaining_tiles.size()):
				var tile: Vector2 = remaining_tiles[j]
				var distance: float = tile.distance_to(last_waypoint)
				
				if distance >= min_waypoint_distance:
					waypoints.append(tile)
					remaining_tiles.remove_at(j)
					last_waypoint = tile
					break
	
	_set_waypoints(waypoints)


## Generates fallback waypoints in a circular pattern around spawn.
func _generate_fallback_waypoints() -> void:
	var waypoints: Array[Vector2] = []
	var angle_step: float = TAU / waypoint_count
	
	for i in range(waypoint_count):
		var angle: float = i * angle_step
		var offset: Vector2 = Vector2(cos(angle), sin(angle)) * (patrol_radius * 0.7)
		waypoints.append(spawn_position + offset)
	
	_set_waypoints(waypoints)


## Checks if a position is walkable (not blocked by obstacles).
func _is_walkable_position(pos: Vector2) -> bool:
	var space_state := get_world_2d().direct_space_state
	var params := PhysicsPointQueryParameters2D.new()
	params.position = pos
	params.collision_mask = 1  # Obstacle layer
	var collision := space_state.intersect_point(params)
	return collision.is_empty()


## Sets waypoints in the blackboard.
func _set_waypoints(waypoints: Array[Vector2]) -> void:
	if not bt_player:
		push_error("BTPlayer not found")
		return
	
	var blackboard: Blackboard = bt_player.get_blackboard()
	if not blackboard:
		push_error("Blackboard not found")
		return
	
	blackboard.set_var(&"waypoints", waypoints)
	blackboard.set_var(&"patrol_index", 0)
	
	print("Stealth enemy: Set %d patrol waypoints" % waypoints.size())


func _update_labels() -> void:
	if not bt_player:
		return
	
	var blackboard: Blackboard = bt_player.get_blackboard()
	if not blackboard:
		return
	
	# Update current state label (show Alert Level: 0=Passive, 1=Cautious, 2=Investigating, 3=Engaged)
	if current_state_label:
		var alert_level: int = 0
		if blackboard.has_var(&"alert_level"):
			alert_level = blackboard.get_var(&"alert_level")
		
		var state_name: String
		match alert_level:
			0: state_name = "Passive"
			1: state_name = "Cautious"
			2: state_name = "Investigating"
			3: state_name = "Engaged"
			_: state_name = "Unknown"
		
		current_state_label.text = "Alert Level: %d (%s)" % [alert_level, state_name]
	
	# Update awareness progress bar
	if awareness_progress_bar:
		var awareness: float = 0.0
		if blackboard.has_var(&"awareness"):
			awareness = blackboard.get_var(&"awareness")
		
		awareness_progress_bar.value = awareness
