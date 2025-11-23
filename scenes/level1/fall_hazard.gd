extends Area2D

@export var fixed_respawn : Vector2

func _ready() -> void:
    body_entered.connect(
        func(value):
            if value is Player:
                if value.on_moving_platform:
                    return
                value.kill()
            elif value is RadChunk:
                if value.on_moving_platform:
                    return
                var tween = value.create_tween()
                tween.tween_property(value, "modulate:a", 0.0, 1)
                tween.tween_callback(func():value.global_position = fixed_respawn)
                tween.tween_callback(func():value.modulate.a = 1.0),
    )