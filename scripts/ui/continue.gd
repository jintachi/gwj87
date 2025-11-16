extends Button

@export var target_scene : PackedScene

func _ready() -> void:
	if not SaveManager.myData:
		visible = false
	pressed.connect(continue_game)

func continue_game() -> void:
	# TODO: Load game
	TransitionScene.transition_to(target_scene)
	pass
