extends Control

@onready var geiger = get_node("%Geiger")
@onready var wifi_signal = get_node("%WifiSignal")
@onready var health_text = get_node("%HealthText")

func update_health_display(health, max_health):
    wifi_signal.material.set_shader_parameter("signal_strength", health / max_health)
    health_text.text = str(int(health))

    