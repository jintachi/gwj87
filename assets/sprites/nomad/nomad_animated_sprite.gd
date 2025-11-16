@tool
extends AnimatedSprite2D

signal radiation_amount_change

@export var geiger_audio_toggle : bool = true
@onready var geiger_blink : GPUParticles2D = $GPUParticles2D
@onready var audio_stream : AudioStreamPlayer2D = $AudioStreamPlayer2D
@export var rad_audio_streams = []

@export_range(0, 1) var radiation_amount : float = 0.0:
	set(value):
		radiation_amount = value
		radiation_amount_change.emit()

signal debug_hitflash
@export var debug_play_hitflash : bool = false:
	set(value):
		debug_play_hitflash = value
		if value:
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

func _ready():
	debug_hitflash.connect(play_hitflash)
	animation_changed.connect(
		func():
			if animation.begins_with("crouch"):
				geiger_blink.position = Vector2(5, -3)
			else:
				geiger_blink.position = Vector2(6, -12),
	)
	radiation_amount_change.connect(
		func():
			geiger_blink.lifetime = 1 - radiation_amount
			if !geiger_audio_toggle:
				audio_stream.stop()
				return
			if radiation_amount < 0.5:
				audio_stream.stream = rad_audio_streams[0]
			elif radiation_amount < 0.6:
				audio_stream.stream = rad_audio_streams[1]
			elif radiation_amount >= 0.70:
				audio_stream.stream = rad_audio_streams[2]
			audio_stream.pitch_scale = 1 + radiation_amount * 0.5
			audio_stream.play(),
	)
	animation = "idle"
	play()
