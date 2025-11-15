extends CharacterBody2D
class_name Entity

signal effect_added
signal effect_removed

var effects : Array[Effect]

func add_effect(effect: Effect) -> void:
	effects.append(effect)
	effect.add_effect(self)
	effect_added.emit(effect)

func remove_effect(effect: Effect) -> void:
	effects.erase(effect)
	effect.remove_effect(self)
	effect_removed.emit(effect)
