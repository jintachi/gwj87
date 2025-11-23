extends Node2D

@onready var area :=  $Area2D
@export var dim_alpha = 0.3
@export var dim_transition_duration = 0.5
var original_alpha : float = 1.0
var counter : int = 0
var tween : Tween

func _ready() -> void:
	original_alpha = modulate.a
	area.body_entered.connect(inc)
	area.body_exited.connect(dec)

func apply_alpha(a: float): modulate.a = a

func inc(_body: Node2D):
	counter += 1
	if counter != 1: return
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_method(apply_alpha, modulate.a, dim_alpha, dim_transition_duration)
func dec(_body: Node2D): 
	counter -= 1
	if counter != 0: return
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_method(apply_alpha, modulate.a, original_alpha, dim_transition_duration)
