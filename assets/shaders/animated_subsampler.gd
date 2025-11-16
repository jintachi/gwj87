@tool
extends AnimatedSprite2D

var mat

func _ready() -> void:
    mat = material
    frame_changed.connect(
        func():
        mat.set_shader_parameter("pic", sprite_frames.get_frame_texture("default", frame))
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