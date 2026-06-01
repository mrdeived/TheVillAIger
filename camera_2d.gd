extends Camera2D

@export var zoom_step: float = 0.5
@export var min_zoom: float = 1.0
@export var max_zoom: float = 8.0
@export var starting_zoom: float = 4.0

func _ready() -> void:
	enabled = true
	make_current()
	zoom = Vector2(starting_zoom, starting_zoom)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			change_zoom(zoom_step)

		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			change_zoom(-zoom_step)


func change_zoom(amount: float) -> void:
	var new_zoom_value := zoom.x + amount
	new_zoom_value = clamp(new_zoom_value, min_zoom, max_zoom)
	zoom = Vector2(new_zoom_value, new_zoom_value)
