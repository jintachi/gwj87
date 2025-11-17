extends RefCounted
class_name SavedNode

var path : String

func save(node: Node, save_path: String):
	var scene = PackedScene.new()
	SaveManager.set_owner_recursive(node, node)
	scene.pack(node)
	ResourceSaver.save(scene, save_path)
	path = save_path

func restore(parent: Node, save_path: String):
	path = save_path
	var scene = ResourceLoader.load(path, type_string(typeof(PackedScene))) as PackedScene
	var instance = scene.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
	parent.add_child(instance)
