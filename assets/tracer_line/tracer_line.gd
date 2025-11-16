extends Sprite2D
class_name TracerLine

@export var follow_mouse : bool = false
@onready var mat : Material = self.material
var square_radius : float
@export var square_range : float = 256:
	set(value):
		square_range = value
		texture.width = square_range
		texture.height = square_range
		square_radius = square_range / 2

func set_point1(target_global_position : Vector2):
	mat.set_shader_parameter("point2", to_local(target_global_position) / square_radius)

func set_point2(target_global_position : Vector2):
	mat.set_shader_parameter("point2", to_local(target_global_position) / square_radius)

func reset_tracer():
	mat.set_shader_parameter("point1", Vector2.ZERO)
	mat.set_shader_parameter("point2", Vector2.ZERO)

func _ready() -> void:
	material = self.material.duplicate()
	mat = material

func _process(delta: float) -> void:
	if follow_mouse:
		set_point2(get_global_mouse_position())