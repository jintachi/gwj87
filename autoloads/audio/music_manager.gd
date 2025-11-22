extends Node

@onready var main: AudioStreamPlayer2D = $Main
@onready var main_crossfade: AudioStreamPlayer2D = $Main_Crossfade

func crossfade_to(stream: AudioStream, duration: float = 4.0, target_volume: float = 1.0, from_time: float = 0.0) -> void:
	if main.stream == stream: return
	main_crossfade.stream = main.stream
	main_crossfade.volume_linear = main.volume_linear
	main_crossfade.pitch_scale = main.pitch_scale
	main_crossfade.area_mask = main.area_mask
	
	main.volume_linear = 0.0
	main.stream = stream
	main.play(from_time)
	
	var tween = create_tween()
	tween.set_parallel()
	tween.set_ignore_time_scale()
	tween.tween_property(main, "volume_linear", target_volume, duration).set_ease(Tween.EASE_OUT)
	tween.tween_property(main_crossfade, "volume_linear", 0.0, duration).set_ease(Tween.EASE_IN)
	tween.play()
	
	await tween.finished
