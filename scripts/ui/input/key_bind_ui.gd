@tool
extends Control

@export var action : InputEventAction
@onready var main_label: Label = $Label

var rebinding : int = -1
var old_event : InputEvent

@onready var primary: Button = $Primary
@onready var primary_label: RichTextLabel = $Primary/Label

@onready var alternative: Button = $Alternative
@onready var alternative_label: RichTextLabel = $Alternative/Label

signal new_key

func _ready() -> void:
	InputMap.load_from_project_settings()
	action.changed.connect(update_label)
	update_label()
	update_display(ArrEx.get_or(InputMap.action_get_events(action.action), 0, null), primary_label)
	update_display(ArrEx.get_or(InputMap.action_get_events(action.action), 1, null), alternative_label)
	if not Engine.is_editor_hint():
		primary.pressed.connect(rebind_primary)
		alternative.pressed.connect(rebind_alternative)

func update_label() -> void:
	if action:
		main_label.text = action.action.capitalize()

func update_display(event: InputEvent, label: RichTextLabel) -> void:
	label.clear()
	if not event: 
		label.add_text("N/A")
		label.tooltip_text = "Not assigned"
		return
	if KeyIcons.add_tags(label, event) < 0:
		label.clear()
		label.add_text(event.as_text().trim_suffix(" (Physical)"))
	label.tooltip_text = event.as_text()

func _input(event: InputEvent) -> void:
	if rebinding >= 0:
		if event is InputEventMouse and not event.is_pressed(): return
		if event is InputEventJoypadMotion and abs(event.axis_value) < 0.5: return
		if event is InputEventKey and event.keycode == KEY_ESCAPE:
			new_key.emit(old_event)
			return
		new_key.emit(event)
		accept_event()

func rebind_primary() -> void:
	rebind(0)
	
func rebind_alternative() -> void:
	rebind(1)

func rebind(index: int) -> void:
	old_event = InputMap.action_get_events(action.action)[index]
	InputMap.action_erase_event(action.action, null)
	rebinding = index
	var new_event : InputEvent = await new_key
	if new_event:
		InputMap.action_add_event(action.action, new_event)
		update_display(new_event, primary_label if index == 0 else alternative_label)
		rebinding = -1
