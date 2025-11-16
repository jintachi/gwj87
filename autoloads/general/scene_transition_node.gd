extends Node
class_name SceneTransitionNode

@onready var transition: TextureRect = $CanvasLayer/TextureRect
@export var duration : float = 2.0

func transition_to(scene: PackedScene):
	var fade_in = get_tree().create_tween()
	fade_in.tween_method(set_radius, 1.0, 0.0, duration)
	fade_in.set_ease(Tween.EASE_OUT)
	fade_in.play()
	
	await fade_in.finished
	
	get_tree().change_scene_to_packed(scene)
	
	var fade_out = get_tree().create_tween()
	fade_out.tween_method(set_radius, 0.0, 1.0, duration)
	fade_out.set_ease(Tween.EASE_IN)
	fade_out.play()
	
	await fade_out.finished

func set_radius(progress: float) -> void:
	(transition.material as ShaderMaterial).set_shader_parameter("radius", progress)
