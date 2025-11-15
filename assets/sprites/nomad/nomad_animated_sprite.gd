@tool
extends AnimatedSprite2D

signal radiation_amount_change

@export var geiger_audio_toggle : bool = true
@onready var geiger_blink : GPUParticles2D = $GPUParticles2D
@onready var audio_stream : AudioStreamPlayer2D = $AudioStreamPlayer2D
@export var rad_audio_streams = []

@export_range(0, 1) var radiation_amount : float = 0.0:
    set(value):
        radiation_amount = value
        radiation_amount_change.emit()
        


func _ready():
    animation_changed.connect(
        func():
            if animation.begins_with("crouch"):
                geiger_blink.position = Vector2(5, -3)
            else:
                geiger_blink.position = Vector2(6, -12),
    )
    radiation_amount_change.connect(
        func():
            geiger_blink.lifetime = 1 - radiation_amount
            if !geiger_audio_toggle:
                audio_stream.stop()
                return
            if radiation_amount < 0.5:
                audio_stream.stream = rad_audio_streams[0]
            elif radiation_amount < 0.6:
                audio_stream.stream = rad_audio_streams[1]
            elif radiation_amount >= 0.70:
                audio_stream.stream = rad_audio_streams[2]
            audio_stream.pitch_scale = 1 + radiation_amount * 0.5
            audio_stream.play(),
    )