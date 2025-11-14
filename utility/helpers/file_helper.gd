## Contains any and all methods relating to file handling that are helpful.
class_name FileHelper

## Used specifically with Web export to load assets because of how export name-changing works.
static func load_asset(path : String) -> Resource:
	if OS.has_feature("export"):
		# Check if file is .remap
		if not path.ends_with(".remap"):
			return load(path)
		
		# Open the file
		var __config_file = ConfigFile.new()
		__config_file.load(path)
		
		# Load the remapped file
		var __remapped_file_path = __config_file.get_value("remap", "path")
		__config_file = null
		return load(__remapped_file_path)
	else:
		return load(path)
