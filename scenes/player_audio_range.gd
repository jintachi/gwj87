#*
#* player_audio_range.gd
#* =============================================================================
#* Visual debug circle for player audio emission range.
#* =============================================================================
#*
extends Node2D

## Audio emission range (should match enemy hearing range).
@export var audio_range: float = 300.0

## Color of the audio range circle.
@export var circle_color: Color = Color(1.0, 0.5, 0.0, 0.3)  # Orange, semi-transparent

## Number of points to draw the circle.
@export var circle_points: int = 64

var _circle_points: PackedVector2Array = []


func _ready() -> void:
	_generate_circle_points()


func _generate_circle_points() -> void:
	_circle_points.clear()
	for i in range(circle_points + 1):
		var angle: float = (i / float(circle_points)) * TAU
		var point: Vector2 = Vector2(cos(angle), sin(angle)) * audio_range
		_circle_points.append(point)


func _draw() -> void:
	draw_polyline(_circle_points, circle_color, 2.0, true)


func _process(_delta: float) -> void:
	queue_redraw()
