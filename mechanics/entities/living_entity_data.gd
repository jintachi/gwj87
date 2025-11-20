extends Resource
class_name LivingEntityData

@export_category("Health")

@export var max_health : float = 100.0
@export var base_armor : float = 0.0

@export var physical_shield : float = 0.0
@export var max_physical_shield : float = 0.0

@export var radiation_shield : float = 0.0
@export var max_radiation_shield : float = 0.0

@export var weather_shield : float = 0.0
@export var max_weather_shield : float = 0.0

@export_category("Movement")

@export var movement_speed : float = 1.0
@export var weight : float = 60.0
@export var friction : float = 1.0

@export var sneak_speed_multiplier : float = 0.6
@export var sneak_transition_duration : float = 0.0
@export var sneak_transition_curve : Curve2D
@export var sneak_weight_multiplier : float = 0.4
