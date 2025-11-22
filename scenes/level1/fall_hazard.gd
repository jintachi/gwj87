extends Area2D

func _ready() -> void:
    body_entered.connect(func(value):print("no"),)