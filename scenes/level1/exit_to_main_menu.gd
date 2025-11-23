extends MarginContainer

@onready var exit_to_main_menu_btn: Button = $"Exit To Main Menu"
const MAIN_MENU = preload("uid://bf6gykjcjcmok")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	exit_to_main_menu_btn.pressed.connect(exit_to_main_menu)

func exit_to_main_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
