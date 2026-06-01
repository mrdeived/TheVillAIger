extends Node2D

func _ready() -> void:
	print("Input debug script ready")


func _input(event: InputEvent) -> void:
	print("Input event: ", event.as_text())
