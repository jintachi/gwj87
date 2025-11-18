@tool
extends PathFollow2D

@export var speed = 1.0
@export var max_range : float = 0.4
@export var min_range : float = 0.2
@export var max_wait_interval : float = 1
@export var min_wait_interval : float = 0.5

func _ready() -> void:
    patrol()

func patrol():
    var tween = create_tween()
    var current_progress = progress_ratio
    tween.tween_method(
        func(value):
            progress_ratio = value,
        current_progress, current_progress + randf_range(min_range, max_range), 1.0 * speed
    ).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
    tween.tween_interval(randf_range(min_wait_interval, max_wait_interval))
    tween.finished.connect(patrol)