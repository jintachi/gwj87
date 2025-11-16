extends Button

func _ready() -> void:
	pressed.connect(start_new_game)

func start_new_game() -> void:
	pass
