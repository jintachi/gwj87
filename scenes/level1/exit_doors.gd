extends Node2D

@onready var exit_door_right: Sprite2D = $ExitDoorRight
@onready var right_barrier := $RightDoor
@onready var exit_door_left: Sprite2D = $ExitDoorLeft
@onready var left_barrier := $LeftDoor
@onready var terminal1 := $Terminal1
@onready var terminal2 := $Terminal2
var open_state = false

func _ready() -> void:
    terminal1.body_entered.connect(check_overlaps)
    terminal2.body_entered.connect(check_overlaps)


func check_overlaps(body):
    var list = []
    list.append(terminal1.get_overlapping_bodies())
    list.append(terminal2.get_overlapping_bodies())
    var count = 0
    for item in list:
        if item is RadChunk:
            count += 1
    if count >= 2:
        open_doors()

func open_doors():
    if open_state: return
    open_state = true
    var mat_1 = exit_door_left.material
    var mat_2 = exit_door_right.material
    var tween = create_tween()

    tween.set_parallel()
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