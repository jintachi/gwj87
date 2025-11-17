extends Node

signal gameLoaded
signal gameSaved # for popups or similar
signal loadError
signal saveError

var myData : SaveData

func set_owner_recursive(node: Node, new_owner: Node):
	for child in node.get_children():
		set_owner_recursive(child, new_owner)
	node.set_owner(new_owner)

func save_data(data: SaveData, path: String = "savegame.save") -> void:
	# if data is null, then throw!
	data.save_all()
	var save_file : FileAccess = FileAccess.open("user://"+path, FileAccess.WRITE)
	if !save_file:
		saveError.emit(FileAccess.get_open_error())
		return
	
	if save_file.store_string(JSON.stringify(JSON.from_native(data, true))):
		gameSaved.emit()
	else:
		saveError.emit(Error.ERR_CANT_CREATE)

func load_data(path: String = "savegame.save") -> SaveData:
	var full_path = "user://"+path;
	if not FileAccess.file_exists(full_path):
		loadError.emit(Error.ERR_DOES_NOT_EXIST);
		return
	
	var save_file = FileAccess.open(full_path, FileAccess.READ)
	if !save_file:
		saveError.emit(FileAccess.get_open_error())
		return
	var data = JSON.to_native(JSON.parse_string(save_file.get_as_text()), true)
	gameLoaded.emit()
	return data
