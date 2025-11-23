extends Control

@onready var geiger = get_node("%Geiger")
var geiger_mat
@onready var wifi_signal = get_node("%WifiSignal")
var wifi_mat
@onready var health_text = get_node("%HealthText")

func _ready() -> void:
    geiger_mat = geiger.material
    wifi_mat = wifi_signal.material

func update_health_display(health, max_health):
    wifi_mat.set_shader_parameter("signal_strength", health / max_health)
    health_text.text = str(int(health))

func update_radiation_display(value):
    geiger_mat.set_shader_parameter("noise_strength", value)
