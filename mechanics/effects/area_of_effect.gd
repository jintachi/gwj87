extends Area2D

@export var effect : Effect

var applied_effects : Dictionary[Entity, Effect]

func _ready() -> void:
	body_entered.connect(add_effect)
	body_exited.connect(remove_effect)

func add_effect(body: Node2D) -> void:
	if body is not Entity: return
	var entity = body as Entity
	var copy = effect.duplicate()
	entity.add_effect(copy)
	applied_effects[entity] = copy
	
func remove_effect(body: Node2D) -> void:
	if body is not Entity: return
	var entity = body as Entity
	entity.remove_effect(applied_effects[entity])
