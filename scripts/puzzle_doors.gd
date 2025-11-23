extends Node2D

var open_state : bool = false
@export var animation_duration : float = 0.5

@onready var blast_door_right: Sprite2D = $BlastDoorRight
@onready var right_barrier := $RightDoor
@onready var blast_door_left: Sprite2D = $BlastDoorLeft
@onready var left_barrier := $LeftDoor
@onready var terminal_glow : Sprite2D = $TerminalGlow
@onready var audio : AudioStreamPlayer2D = $AudioStreamPlayer2D
var glow_mat

@onready var area_2d: Area2D = $Area2D


func _ready() -> void:
	area_2d.body_entered.connect(break_if_rad_chunk)
	glow_mat = terminal_glow.material

func break_if_rad_chunk(body: Node2D) -> void:
	if body is RadChunk:
		open_doors()

func open_doors() -> void:
	if open_state: return
	open_state = true
	var gap = Vector2(60, 0)
	var mat_1 = blast_door_left.material
	var mat_2 = blast_door_right.material
	var tween = create_tween()

	tween.tween_method(
		func(value):
			if fmod(floor(exp(value)), 2) == 0:
				terminal_glow.visible = false
			else:
				terminal_glow.visible = true,
		0, 30, 4
	)
	tween.set_parallel()
	tween.tween_callback(func():audio.play())
	tween.tween_method(
		func(value):
			mat_1.set_shader_parameter("clip_amount", value),
		0.0, .60, 5
	).set_trans(Tween.TRANS_EXPO)
	tween.tween_method(
		func(value):
			mat_2.set_shader_parameter("clip_amount", value),
		0.0, -.60, 5
	).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(right_barrier, "position:x", right_barrier.position.x + 64, 5).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(left_barrier, "position:x", left_barrier.position.x -64, 5).set_trans(Tween.TRANS_EXPO)
