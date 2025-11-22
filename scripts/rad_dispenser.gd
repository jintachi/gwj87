extends Sprite2D
const RAD_CHUNK = preload("uid://cfb4u81tpku1j")
@export var spawn_offset : Vector2
@export var regen_duration : float = 5.0
@export var animation_duration : float = 0.6
@export var spawn_curve_width : Curve
@export var spawn_curve_y : Curve

func _ready() -> void:
	get_tree().create_timer(regen_duration / 2.0).timeout.connect(spawn_rad_chunk)

func spawn_rad_chunk() -> void:
	var instance : RadChunk = RAD_CHUNK.instantiate()
	instance.global_position = global_position + Vector2(0, spawn_curve_y.sample(0.0))
	add_child(instance)

	var tween = create_tween()
	tween.tween_method(func(progress): 
		instance.global_position = global_position + Vector2(0, spawn_curve_y.sample(progress))
		instance.scale.x = spawn_curve_width.sample(progress)
	, 0.0, 1.0, animation_duration)
	tween.play()
	
	instance.picked_up.connect(tween.kill)
	instance.picked_up.connect(func():
		get_tree().create_timer(regen_duration).timeout.connect(spawn_rad_chunk))
