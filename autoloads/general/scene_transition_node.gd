extends Node
class_name SceneTransitionNode

@onready var transition: TextureRect = $CanvasLayer/TextureRect
@export var duration : float = 2.0

func transition_to(scene: PackedScene) -> void:
	await fade_in()
	get_tree().change_scene_to_packed(scene)
	await fade_out()

func reload() -> void:
	await fade_in()
	get_tree().reload_current_scene()
	await fade_out()

func fade_in() -> void:
	var fade_in_tween = get_tree().create_tween()
	fade_in_tween.tween_method(set_radius, 1.0, 0.0, duration)
	fade_in_tween.set_ease(Tween.EASE_OUT)
	fade_in_tween.play()
	
	await fade_in_tween.finished

func fade_out() -> void:
	var fade_out_tween = get_tree().create_tween()
	fade_out_tween.tween_method(set_radius, 0.0, 1.0, duration)
	fade_out_tween.set_ease(Tween.EASE_IN)
	fade_out_tween.play()
	
	await fade_out_tween.finished

func set_radius(progress: float) -> void:
	(transition.material as ShaderMaterial).set_shader_parameter("radius", progress)
