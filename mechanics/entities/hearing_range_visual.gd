#*
#* hearing_range_visual.gd
#* =============================================================================
#* Visual circle for hearing range with gradient fade from center to edge.
#* =============================================================================
#*
extends Node2D

## Hearing detection range.
@export var hearing_range: float = 150.0

## Color of the hearing range circle (alpha will be modified for gradient).
@export var circle_color: Color = Color(0.0, 1.0, 0.0, 1.0)  # Green

## Number of gradient layers (more = smoother gradient, but more expensive).
@export var gradient_layers: int = 20

## Center alpha (at center of circle).
@export var center_alpha: float = 1.0

## Edge alpha (at edge of circle).
@export var edge_alpha: float = 0.5

## Number of points for circle smoothness.
@export var circle_points: int = 64


func _ready() -> void:
	# Make sure we draw behind other sprites
	z_index = -1


func _draw() -> void:
	# Draw gradient circle using concentric rings (donuts)
	# Each ring has a different alpha to create smooth gradient
	for layer in range(gradient_layers):
		var inner_radius: float = (hearing_range / float(gradient_layers)) * layer
		var outer_radius: float = (hearing_range / float(gradient_layers)) * (layer + 1)
		
		# Use outer radius for alpha calculation (fade from center to edge)
		var normalized_distance: float = float(layer + 1) / float(gradient_layers)
		
		# Interpolate alpha from center (1.0) to edge (0.5)
		var layer_alpha: float = center_alpha - (normalized_distance * (center_alpha - edge_alpha))
		
		# Create color with interpolated alpha
		var layer_color: Color = circle_color
		layer_color.a = layer_alpha
		
		# Generate ring points (outer circle + inner circle reversed)
		var ring_vertices: PackedVector2Array = []
		
		# Outer circle (clockwise)
		for i in range(circle_points + 1):
			var angle: float = (i / float(circle_points)) * TAU
			var point: Vector2 = Vector2(cos(angle), sin(angle)) * outer_radius
			ring_vertices.append(point)
		
		# Inner circle (counter-clockwise to close the polygon)
		for i in range(circle_points, -1, -1):
			var angle: float = (i / float(circle_points)) * TAU
			var point: Vector2 = Vector2(cos(angle), sin(angle)) * inner_radius
			ring_vertices.append(point)
		
		# Draw filled ring
		draw_colored_polygon(ring_vertices, layer_color)


func _process(_delta: float) -> void:
	queue_redraw()
