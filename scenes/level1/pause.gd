extends MarginContainer

@export var menu_overlay : Control
@onready var resume: Button = $Resume

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	resume.pressed.connect(unpause)

func unpause() -> void:
	get_tree().paused = false
	menu_overlay.visible = false
