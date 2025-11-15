extends Resource
class_name SaveData

signal save

# and you're supposed to set all of these when save signal is emitted
@export var testing : int = 0
@export var testin2 : int = 1
@export var foo : String = "Hello"
var savedNode : SavedNode

func save_all() -> void:
	save.emit()
