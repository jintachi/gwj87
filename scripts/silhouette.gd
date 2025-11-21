extends Sprite2D

@export var parent : Sprite2D

func _process(_delta: float) -> void:
	texture = parent.texture
	offset = parent.offset
	flip_h = parent.flip_h
	flip_v = parent.flip_v
	hframes = parent.hframes
	vframes = parent.vframes
	centered = parent.centered
	frame = parent.frame
	visible = parent.visible
