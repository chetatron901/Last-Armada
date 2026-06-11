extends CharacterBody3D

@export_category("Camera settings")
@export var max_lean: float = 10.0
@export var lean_sensitivity_x: float = 0.05
@export var lean_sensitivity_y: float = 0.025
@export var return_delay: float = 0.1
@export var return_speed: float = 10.0

@onready var camera: Camera3D = $Camera3D
@onready var timer: Timer = $Timer

var mouse_idle: bool = false
var focused: bool = true
var camera_origin: Vector3

func _ready() -> void:
	camera_origin = camera.position
	timer.timeout.connect(_on_timer_timeout)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and focused:
		var mouse_x: float = event.relative.x
		var mouse_y: float = event.relative.y
		
		# move cam based on relative mouse pos
		camera.position.x -= mouse_x * lean_sensitivity_x
		camera.position.y -= mouse_y * lean_sensitivity_y
		
		# clamp RELATIVE to camera_origin
		camera.position.x = clamp(camera.position.x, camera_origin.x - max_lean, camera_origin.x + max_lean)
		camera.position.y = clamp(camera.position.y, camera_origin.y - max_lean, camera_origin.y + max_lean)
		
		mouse_idle = false
		timer.start(return_delay) 
		
		#!! ADD IN FIGHTER TURNING LOGIC LATER
		
		#free mouse with esc
	elif event.is_action_pressed("ui_cancel") and focused:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		focused = false
		
		#lock mouse when return
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and not focused:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		focused = true

func _physics_process(delta: float) -> void:
	if mouse_idle and focused:
		# smoothly lerp cam back to origin
		camera.position = camera.position.lerp(camera_origin, return_speed * delta)

func _on_timer_timeout() -> void:
	mouse_idle = true
