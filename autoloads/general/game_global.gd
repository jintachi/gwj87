## The actual Global containing all of the game's core information.
extends Node

#region Built-Ins
func _ready() -> void:
	pass
#endregion

#region Helpers
func delay(time: float) -> void:
	await get_tree().create_timer(time).timeout
#endregion
