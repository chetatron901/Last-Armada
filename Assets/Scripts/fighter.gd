extends CharacterBody3D

@export_category("Movement")
@export var forward_speed: float = 50.0
@export var turn_speed: float = 2.0

@export_category("Misc")
@export var deadzone_radius: float = 20.0 # (pixels)

var screen_centre: Vector2
var mouse_offset: Vector2 = Vector2.ZERO
var is_focused: bool = true

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	
	screen_centre = get_viewport().get_visible_rect().size / 2.0

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_offset = event.position - screen_centre
	elif event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT and not is_focused:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		Input.mouse_mode = Input.MOUSE_MODE_CONFINED
		is_focused = true

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_action_pressed("ui_cancel") and is_focused:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		is_focused = false

func _physics_process(delta: float) -> void:
	velocity = transform.basis.z * forward_speed
	move_and_slide()
	
	if mouse_offset.length() > deadzone_radius and is_focused:
		var screen_size = get_viewport().get_visible_rect().size
		var normalised_tether = Vector2(
			mouse_offset.x / (screen_size.x / 2.0),
			mouse_offset.y / (screen_size.y / 2.0)
		)
		
		normalised_tether = normalised_tether.limit_length(1.0)
		
		var pitch_input = -normalised_tether.y * turn_speed * delta
		var yaw_input = -normalised_tether.x * turn_speed * delta
		
		rotate_object_local(Vector3.RIGHT, pitch_input)
		rotate_y(yaw_input)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_SIZE_CHANGED:
		screen_centre = get_viewport().get_visible_rect().size / 2.0
