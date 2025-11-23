extends Sprite2D

const RAD_CHUNK = preload("uid://cfb4u81tpku1j")
@onready var area :Area2D = $Area2D
@export var empty_texture : Texture2D
var in_range := false
@onready var has_chunk := true

func _ready() -> void:
    area.body_entered.connect(func(value): if value is Player: in_range = true)
    area.body_exited.connect(func(value):if value is Player: in_range = false)

func _input(event: InputEvent) -> void:
    if !in_range: return
    if has_chunk and Input.is_action_just_pressed("interact"):
        has_chunk = false
        var instance : RadChunk = RAD_CHUNK.instantiate()
        add_child(instance)
        var dir = Vector2(randf_range(-1,1),randf_range(-1,1)).normalized() * 64
        instance.apply_impulse(dir)
        self.texture = empty_texture


#This is horrendous. I have no choice but do it this way because I want around the current player interaction system.