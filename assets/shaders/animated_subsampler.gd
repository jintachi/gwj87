@tool
extends AnimatedSprite2D

var mat

signal debug_hitflash
@export var debug_play_hitflash : bool = false:
	set(value):
		if value:
			debug_play_hitflash = value
			debug_hitflash.emit()


func play_hitflash() -> void:
	var mat = material
	var tween = get_tree().create_tween()
	tween.tween_callback(func():mat.set_shader_parameter("enable_fill", true))
	tween.chain().tween_callback(func():mat.set_shader_parameter("fill_color", Color.WHITE))
	tween.chain().tween_interval(0.1)
	tween.chain().tween_callback(func():mat.set_shader_parameter("fill_color", Color.BLACK))
	tween.chain().tween_interval(0.05)
	tween.chain().tween_callback(func():mat.set_shader_parameter("enable_fill", false))


func _ready() -> void:
	mat = material
	debug_hitflash.connect(play_hitflash)
	frame_changed.connect(
		func():
		mat.set_shader_parameter("pic", sprite_frames.get_frame_texture(animation, frame))
	)
	play()
	hover()

func hover():
	var tween = create_tween()
	tween.tween_method(
		func(value):
			mat.set_shader_parameter("origin", Vector2(0, sin(value) * 0.05)),
		0.0, 2.0*PI, 2
	)
	tween.finished.connect(hover)
