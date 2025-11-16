extends Button

@export var target_scene : PackedScene

func _ready() -> void:
	pressed.connect(start_new_game)

func start_new_game() -> void:
	TransitionScene.transition_to(target_scene)
	pass
