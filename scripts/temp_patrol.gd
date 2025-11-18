@tool
extends PathFollow2D

@export var speed = 1.0
@export var max_range : float = 0.4
@export var min_range : float = 0.2
<<<<<<< HEAD
@export var max_wait_interval : float = 1
@export var min_wait_interval : float = 0.5
=======
@export var default_progress_ratio : float = 0
@export var preview : bool = false:
	set(set_preview):
		if not set_preview and patrol_tween:
			patrol_tween.kill()
			progress_ratio = default_progress_ratio
		preview = set_preview
		patrol()
		

var patrol_tween : Tween
>>>>>>> origin/fcolor04

func _ready() -> void:
	progress_ratio = default_progress_ratio
	patrol()

func patrol():
<<<<<<< HEAD
    var tween = create_tween()
    var current_progress = progress_ratio
    tween.tween_method(
        func(value):
            progress_ratio = value,
        current_progress, current_progress + randf_range(min_range, max_range), 1.0 * speed
    ).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
    tween.tween_interval(randf_range(min_wait_interval, max_wait_interval))
    tween.finished.connect(patrol)
=======
	if Engine.is_editor_hint() and not preview: return
	patrol_tween = create_tween()
	var current_progress = progress_ratio
	patrol_tween.tween_method(
		func(value):
			progress_ratio = value,
		current_progress, current_progress + randf_range(min_range, max_range), 1.0 * speed
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	patrol_tween.tween_interval(randf_range(1,1.5))
	patrol_tween.finished.connect(patrol)
>>>>>>> origin/fcolor04
