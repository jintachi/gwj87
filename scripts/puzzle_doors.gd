extends Node2D

var open_state : bool = false
@export var animation_duration : float = 0.5

@onready var blast_door_right: Sprite2D = $BlastDoorRight
@onready var blast_door_left: Sprite2D = $BlastDoorLeft

@onready var static_body_2d: StaticBody2D = $StaticBody2D
@onready var area_2d: Area2D = $Area2D

func _ready() -> void:
	area_2d.body_entered.connect(break_if_rad_chunk)

func break_if_rad_chunk(body: Node2D) -> void:
	if body is RadChunk:
		open_doors()

func open_doors() -> void:
	if open_state: return
	open_state = true
	var gap = Vector2(60, 0)
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_property(blast_door_left, "position", -gap, animation_duration).as_relative()
	tween.tween_property(blast_door_right, "position", gap, animation_duration).as_relative()
	static_body_2d.process_mode = Node.PROCESS_MODE_DISABLED
