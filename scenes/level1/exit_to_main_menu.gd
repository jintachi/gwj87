extends MarginContainer

@export var menu_overlay : Control
@onready var resume: Button = $Resume
const MAIN_MENU = preload("uid://bf6gykjcjcmok")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	resume.pressed.connect(exit_to_main_menu)

func exit_to_main_menu() -> void:
	get_tree().paused = false
	menu_overlay.visible = false
	TransitionScene.transition_to(MAIN_MENU)
