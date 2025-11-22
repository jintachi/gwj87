extends Area2D

@onready var stream_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var collision_polygon_2d: CollisionPolygon2D = $CollisionPolygon2D

@export var debug : bool

@export var inset_length : float = 50.0
@export var filter_check_length : float = 60.0
@export var bus_name : StringName = &"Ambient"
@export var filtered_bus_name : StringName = &"Ambient Filtered"
@export var mask : int = 0

var point : Vector2
var debug_draw_a : Vector2
var debug_draw_b : Vector2

@export var filter : bool = false
var filtered : bool = false
var closest_point: Vector2

func _process(_delta: float) -> void:
	var player : Player = Player.instance
	if player and overlaps_body(player):
		stream_player.global_position = player.global_position
	else:
		if player:
			point = player.global_position
		else:
			point = get_global_mouse_position()
		var polygon = collision_polygon_2d.polygon

		var best_distance: float = INF
		var best_point: Vector2 = Vector2.ZERO

		var count: int = polygon.size()
		if count < 2:
			return

		for i in range(count):
			var p1: Vector2 = polygon[i]
			var p2: Vector2 = polygon[(i + 1) % count]

			var proj: Vector2 = get_closest_point_on_segment(point, p1, p2)
			var dst: float = proj.distance_squared_to(point)

			if dst < best_distance:
				best_distance = dst
				best_point = proj
		closest_point = best_point
		stream_player.global_position = closest_point
		queue_redraw()

func _physics_process(_delta: float) -> void:
	if filter:
		var inverse_vector : Vector2 = closest_point - point
		var vector : Vector2 = -inverse_vector
		var from : Vector2 = inverse_vector.normalized() * inset_length + closest_point
		var to : Vector2 = vector.normalized() * filter_check_length + closest_point
		var query : PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(from, to, mask)
		debug_draw_a = from
		debug_draw_b = to
		var result : Dictionary = get_world_2d().direct_space_state.intersect_ray(query)
		if result:
			filtered = true
			stream_player.bus = filtered_bus_name
		else:
			filtered = false
			stream_player.bus = bus_name


func get_closest_point_on_segment(p: Vector2, a: Vector2, b: Vector2) -> Vector2:
	var ab: Vector2 = b - a
	var t: float = (p - a).dot(ab) / ab.length_squared()

	if t < 0.0:
		t = 0.0
	elif t > 1.0:
		t = 1.0

	return a + ab * t

func _draw() -> void:
	if debug and not debug_draw_b.is_zero_approx():
		draw_line(debug_draw_a, debug_draw_b, Color(1, 0, 0, 1), 2)
		draw_circle(debug_draw_a, 10.0, Color(0, 1, 0, 1) if filtered else Color(0, 0, 1, 1), false, 2)
