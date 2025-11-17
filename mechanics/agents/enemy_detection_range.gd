#*
#* enemy_detection_range.gd
#* =============================================================================
#* Visual debug circles for enemy detection ranges.
#* =============================================================================
#*
extends Node2D

## Vision detection range.
@export var vision_range: float = 400.0

## Hearing detection range.
@export var hearing_range: float = 300.0

## Vision cone angle in degrees (half-angle).
@export var vision_angle: float = 60.0

## Color of the vision range circle.
@export var vision_color: Color = Color(1.0, 0.0, 0.0, 0.2)  # Red, semi-transparent

## Color of the hearing range circle.
@export var hearing_color: Color = Color(0.0, 1.0, 0.0, 0.2)  # Green, semi-transparent

## Color of the vision cone.
@export var vision_cone_color: Color = Color(1.0, 0.0, 0.0, 0.4)  # Red, more opaque

## Number of points to draw the circles.
@export var circle_points: int = 64

var _vision_circle_points: PackedVector2Array = []
var _hearing_circle_points: PackedVector2Array = []
var _vision_cone_points: PackedVector2Array = []


func _ready() -> void:
	_generate_circle_points()


func _generate_circle_points() -> void:
	# Generate vision circle
	_vision_circle_points.clear()
	for i in range(circle_points + 1):
		var angle: float = (i / float(circle_points)) * TAU
		var point: Vector2 = Vector2(cos(angle), sin(angle)) * vision_range
		_vision_circle_points.append(point)
	
	# Generate hearing circle
	_hearing_circle_points.clear()
	for i in range(circle_points + 1):
		var angle: float = (i / float(circle_points)) * TAU
		var point: Vector2 = Vector2(cos(angle), sin(angle)) * hearing_range
		_hearing_circle_points.append(point)
	
	# Generate vision cone
	_generate_vision_cone()


func _generate_vision_cone() -> void:
	_vision_cone_points.clear()
	var half_angle_rad: float = deg_to_rad(vision_angle)
	
	# Start at center
	_vision_cone_points.append(Vector2.ZERO)
	
	# Left edge of cone
	var left_angle: float = -half_angle_rad
	_vision_cone_points.append(Vector2(cos(left_angle), sin(left_angle)) * vision_range)
	
	# Arc of cone
	var arc_points: int = 32
	for i in range(arc_points + 1):
		var angle: float = left_angle + (i / float(arc_points)) * (half_angle_rad * 2)
		var point: Vector2 = Vector2(cos(angle), sin(angle)) * vision_range
		_vision_cone_points.append(point)
	
	# Back to center
	_vision_cone_points.append(Vector2.ZERO)


func _draw() -> void:
	# Draw hearing range (full circle)
	draw_polyline(_hearing_circle_points, hearing_color, 2.0, true)
	
	# Draw vision range (full circle)
	draw_polyline(_vision_circle_points, vision_color, 2.0, true)
	
	# Draw vision cone (needs to be rotated based on facing)
	var parent = get_parent()
	if parent and parent.has_method("get_facing_direction"):
		var facing_dir: Vector2 = parent.get_facing_direction()
		var rotation_angle: float = facing_dir.angle()
		
		var rotated_cone: PackedVector2Array = []
		for point in _vision_cone_points:
			rotated_cone.append(point.rotated(rotation_angle))
		
		draw_colored_polygon(rotated_cone, vision_cone_color)
		draw_polyline(rotated_cone, vision_cone_color * 1.5, 2.0, true)
	elif parent and parent.has_method("get_facing"):
		# Fallback to legacy facing
		var facing: float = parent.get_facing()
		var rotation_angle: float = 0.0 if facing > 0 else PI
		
		var rotated_cone: PackedVector2Array = []
		for point in _vision_cone_points:
			rotated_cone.append(point.rotated(rotation_angle))
		
		draw_colored_polygon(rotated_cone, vision_cone_color)
		draw_polyline(rotated_cone, vision_cone_color * 1.5, 2.0, true)


func _process(_delta: float) -> void:
	queue_redraw()
