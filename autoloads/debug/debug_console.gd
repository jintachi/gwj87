extends CanvasLayer
class_name DebugConsole

static var instance : DebugConsole
var expression = Expression.new()
@onready var input : LineEdit = $Container/VBoxContainer/LineEdit
@onready var out : RichTextLabel = $Container/VBoxContainer/RichTextLabel

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"debug"):
		if visible:
			hide()
		else:
			show()
#endregion

# this could be its own thing I guess, TODO: to be cleaned up
class CustomLogger extends Logger:
	func _log_message(message: String, error: bool) -> void:
		if !DebugConsole.instance:
			return
		if error:
			DebugConsole.instance.out.text += "[color=red]" + message + "[/color]"
		else:
			DebugConsole.instance.out.text += message
		pass

	func _log_error(
			_function: String,
			_file: String,
			_line: int,
			_code: String,
			rationale: String,
			_editor_notify: bool,
			_error_type: int,
			_script_backtraces: Array[ScriptBacktrace]
	) -> void:
		if !DebugConsole.instance:
			return
		DebugConsole.instance.out.text += "[color=red]" + rationale + "[/color]"

func _init() -> void:
	instance = self
	visible = false
	OS.add_logger(CustomLogger.new())

func _ready() -> void:
	input.text_submitted.connect(parse_command)
	
func parse_command(command) -> void:
	var error = expression.parse(command)
	if error != OK:
		out.text += "[color=red]" + expression.get_error_text() + "[/color]\n"
		return
	var result = expression.execute([], self)
	if !expression.has_execute_failed():
		out.text += "[color=gray]>"+input.text+"[/color]\n"
		input.clear()
		if result:
			out.text += ">" + str(result) + "\n"
	else:
		out.text += "[color=red]" + expression.get_error_text() + "[/color]\n"
		return

func saveManager() -> SaveManager: return SaveManager

func save() -> void:
	if !SaveManager.myData:
		SaveManager.myData = SaveData.new()
		SaveManager.myData.foo = "ABC"
		SaveManager.myData.testing = randi_range(0, 10000)
	
	SaveManager.save_data(SaveManager.myData)

func load() -> void:
	SaveManager.myData = SaveManager.load_data()
