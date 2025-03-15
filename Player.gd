extends CharacterBody3D

@onready var head = $Head
@onready var camera = $Head/Camera
#@onready var flashLight = $Head/FlashLight

var currentSpeed

const SPEED = 5.0
const SPRINTSPEED = 8.0
const JUMP_VELOCITY = 4.5
const LOOK_SENSITIVITY = .003

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x *LOOK_SENSITIVITY)
		camera.rotate_x(-event.relative.y*LOOK_SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(60))
		#flashLight.rotation.x = camera.rotation.x
	#if Input.is_action_just_pressed("ToggleFlashlight"):
		#flashLight.visible = false if flashLight.visible  else true

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	currentSpeed = SPRINTSPEED if Input.is_action_pressed("Sprint") else SPEED
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("MoveLeft", "MoveRight", "MoveForward", "MoveBackward")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * currentSpeed
		velocity.z = direction.z * currentSpeed
	else:
		velocity.x = move_toward(velocity.x, 0, currentSpeed)
		velocity.z = move_toward(velocity.z, 0, currentSpeed)

	move_and_slide()
