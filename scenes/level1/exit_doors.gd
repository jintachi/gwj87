extends Node2D

@onready var exit_door_right: Sprite2D = $ExitDoorRight
@onready var right_barrier := $RightDoor
@onready var exit_door_left: Sprite2D = $ExitDoorLeft
@onready var left_barrier := $LeftDoor
@onready var terminal1 := $Terminal1
@onready var terminal1_glow = $Terminal1/Glow
var terminal1_disabled := false
@onready var terminal2 := $Terminal2
@onready var terminal2_glow = $Terminal2/Glow
var terminal2_disabled := false
var open_state = false

func _ready() -> void:
    terminal1.body_entered.connect(
        func(value):
            if value is RadChunk:
                var tween = create_tween()
                tween.tween_method(
                    func(value):
                        if fmod(floor(exp(value)), 2) == 0:
                            terminal1_glow.visible = false
                        else:
                            terminal1_glow.visible = true,
                            0, 30, 4
                )
                tween.finished.connect(
                    func():
                        terminal1_disabled = true
                        terminal1_glow.visible = false
                        check_overlaps(value)
                )
    )
    terminal1.body_exited.connect(
        func(value):
            var check_rad_chunk = null
            for node in terminal1.get_overlapping_areas():
                if node is RadChunk:
                    check_rad_chunk = node
            if check_rad_chunk == null:
                terminal1_disabled = false
                terminal1_glow.visible = true
    )
    
    terminal2.body_entered.connect(
        func(value):
            if value is RadChunk:
                var tween = create_tween()
                tween.tween_method(
                    func(value):
                        if fmod(floor(exp(value)), 2) == 0:
                            terminal2_glow.visible = false
                        else:
                            terminal2_glow.visible = true,
                            0, 30, 4
                )
                tween.finished.connect(
                    func():
                        terminal2_disabled = true
                        terminal2_glow.visible = false
                        check_overlaps(value)
                )
    )
    terminal2.body_exited.connect(
        func(value):
            var check_rad_chunk = null
            for node in terminal2.get_overlapping_areas():
                if node is RadChunk:
                    check_rad_chunk = node
            if check_rad_chunk == null:
                terminal2_disabled = false
                terminal2_glow.visible = true
    )


func check_overlaps(body):
    var list = terminal1.get_overlapping_bodies() + terminal2.get_overlapping_bodies()
    var count = 0
    print(list)
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