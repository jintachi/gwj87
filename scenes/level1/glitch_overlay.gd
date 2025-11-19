extends ColorRect

@export var initial_parameters = []
@export var max_parameters = []
#shake power []
#shake rate
#shake speed
#tearing block size
#color dispersion
var mat 

func _ready() -> void:
	mat = material
	set_radiation_parameters(0)

func set_radiation_parameters(ratio : float):
	if initial_parameters.size() != 5 || max_parameters.size() != 5:
		return
	mat.set_shader_parameter("shake_power", lerp(initial_parameters[0], max_parameters[0], ratio))
	mat.set_shader_parameter("shake_rate", lerp(initial_parameters[1], max_parameters[1], ratio))
	mat.set_shader_parameter("shake_speed", lerp(initial_parameters[2], max_parameters[2], ratio))
	mat.set_shader_parameter("shake_block_size", lerp(initial_parameters[3], max_parameters[3], ratio))
	mat.set_shader_parameter("shake_color_rate", lerp(initial_parameters[4], max_parameters[4], ratio))
