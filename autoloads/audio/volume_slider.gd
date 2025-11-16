extends HSlider

@onready var test_sound: AudioStreamPlayer = $"TestSound"
@export var bus_name : String
var bus_index

func _ready() -> void:
	bus_index = AudioServer.get_bus_index(bus_name)
	value_changed.connect(set_volume)
	value = db_to_linear(AudioServer.get_bus_volume_db(bus_index))
	drag_started.connect(play_sample)
	drag_ended.connect(stop_sample)

func play_sample() -> void:
	test_sound.play()
	pass
	
func stop_sample(_value_changed: bool) -> void:
	test_sound.stop()
	pass

func set_volume(volume: float) -> void:
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(volume))
