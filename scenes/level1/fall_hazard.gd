extends Area2D

func _ready() -> void:
    body_entered.connect(
        func(value):
            if value is Player:
                print("respawn player")
            elif value is RadChunk:
                print("send rad chunk to reasonable location"),
    )