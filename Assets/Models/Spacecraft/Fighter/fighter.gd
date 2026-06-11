extends CharacterBody3D

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
