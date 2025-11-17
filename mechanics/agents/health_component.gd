#*
#* health_component.gd
#* =============================================================================
#* Health component for agents. Handles health and damage.
#* =============================================================================
#*
extends Node
class_name HealthComponent

## Maximum health value.
@export var max_health: float = 100.0

## Current health value.
var current_health: float

## Armor value (reduces incoming damage).
@export var armor: float = 0.0

## Signal emitted when health reaches zero.
signal died

## Signal emitted when taking damage.
signal damage_taken(amount: float, new_health: float)

## Signal emitted when health changes.
signal health_changed(new_health: float, max_health: float)


func _ready() -> void:
	current_health = max_health


## Take damage, reduced by armor.
func take_damage(amount: float) -> void:
	if current_health <= 0.0:
		return
	
	var actual_damage: float = max(0.0, amount - armor)
	current_health = max(0.0, current_health - actual_damage)
	
	damage_taken.emit(actual_damage, current_health)
	health_changed.emit(current_health, max_health)
	
	if current_health <= 0.0:
		died.emit()


## Heal the agent.
func heal(amount: float) -> void:
	current_health = min(max_health, current_health + amount)
	health_changed.emit(current_health, max_health)


## Get current health percentage (0.0 to 1.0).
func get_health_percentage() -> float:
	if max_health <= 0.0:
		return 0.0
	return current_health / max_health


## Check if the agent is dead.
func is_dead() -> bool:
	return current_health <= 0.0

