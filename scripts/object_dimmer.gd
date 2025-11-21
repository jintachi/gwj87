extends Area2D

@export var target : Sprite2D
@export var dim_alpha = 0.3
@export var dim_transition_duration = 0.5
var original_alpha : float = 1.0
var counter : int = 0
var tween : Tween

func _ready() -> void:
	original_alpha = target.modulate.a
	body_entered.connect(inc)
	body_exited.connect(dec)

func apply_alpha(a: float): target.modulate.a = a

func inc(_body: Node2D):
	counter += 1
	print(counter)
	if counter != 1: return
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_method(apply_alpha, target.modulate.a, dim_alpha, dim_transition_duration)
func dec(_body: Node2D): 
	counter -= 1
	print(counter)
	if counter != 0: return
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_method(apply_alpha, target.modulate.a, original_alpha, dim_transition_duration)
