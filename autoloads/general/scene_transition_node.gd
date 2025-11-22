extends Node
class_name SceneTransitionNode

@onready var transition: TextureRect = $CanvasLayer/TextureRect
@export var duration : float = 2.0
@onready var material_preloader: ColorRect = $"CanvasLayer/Material Preloader"

signal preload_materials
static var material_queue : Dictionary[int, Material]

func transition_to(scene: PackedScene) -> void:
	await fade_in()
	get_tree().change_scene_to_packed(scene)
	await get_tree().scene_changed
	material_preloader.visible = true
	preload_materials.emit()
	for material in material_queue.values():
		material_preloader.material = material
		await get_tree().process_frame
	material_queue.clear()
	material_preloader.visible = false
	await fade_out()

func reload(global_checkpoint, player) -> void:
	await fade_in()
	player.global_position = global_checkpoint

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

static func preload_material(material: Material) -> void:
	TransitionScene.preload_materials.connect(func(): material_queue[hash(material)] = material, CONNECT_ONE_SHOT)

func set_radius(progress: float) -> void:
	(transition.material as ShaderMaterial).set_shader_parameter("radius", progress)
