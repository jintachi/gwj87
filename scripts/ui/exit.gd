extends Button

func _ready() -> void:
	if OS.get_name() == "Web":
		disabled = true
		modulate.a = 0
	pressed.connect(exit)

func exit() -> void:
	get_tree().quit()
