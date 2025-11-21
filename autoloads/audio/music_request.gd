extends Node
class_name MusicRequest

@export var music : AudioStream

func _ready() -> void:
	MusicManager.crossfade_to(music)
