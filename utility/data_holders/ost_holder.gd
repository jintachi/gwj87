## Custom Data type that holds an AudioStream (which is supposed to be an OST)
## along with additional data that is supposed to help the MusicManager
class_name OstHolder extends Resource

@export var ost_name : StringName
@export var ost_stream : AudioStream
@export var can_loop : bool = false
@export var loop_vector : Vector2 = Vector2(0, -1)
