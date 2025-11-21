extends Control

@onready var radiation_display = get_node("%RadiationDisplay")
@onready var signal_display = get_node("%SignalDisplay")

@export_range(0, 1.0) var radiation_amount := 0.0:
	set(value):
		radiation_amount = value
		radiation_display.material.set_shader_parameter("noise_strength", value)

@export_range(0, 1.0) var signal_amount := 1.0:
	set(value):
		signal_amount = value
		signal_display.material.set_shader_parameter("signal_strength", value)
