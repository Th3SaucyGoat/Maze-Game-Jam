extends CharacterBody3D

const ResourceType = preload("res://resource_type.gd").ResourceType

@onready var head = $Head
@onready var camera = $Head/Camera
#@onready var flashLight = $Head/FlashLight

@onready var messageBoard = get_node("../MessageBoard")

var currentSpeed

const SPEED = 10.0
const SPRINTSPEED = 18.0
const JUMP_VELOCITY = 8.0
const LOOK_SENSITIVITY = .003

var currentInteractable: Area3D = null
var inventory = {
	ResourceType.WOOD_PLANK: 0,
	ResourceType.NAILS: 0,
	ResourceType.HAMMER: 0,
}

func _ready():
	add_to_group("player")
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
		velocity += get_gravity() *2* delta

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	currentSpeed = SPRINTSPEED if Input.is_action_pressed("Sprint") else SPEED
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var inputDir = Input.get_vector("MoveLeft", "MoveRight", "MoveForward", "MoveBackward")
	var direction = (head.transform.basis * Vector3(inputDir.x, 0, inputDir.y)).normalized()
	if direction:
		velocity.x = direction.x * currentSpeed
		velocity.z = direction.z * currentSpeed
	else:
		velocity.x = move_toward(velocity.x, 0, currentSpeed)
		velocity.z = move_toward(velocity.z, 0, currentSpeed)

	move_and_slide()

func _process(delta: float) -> void:
	interaction()

func _on_area_entered(body: Node3D, area: Area3D):
	if area.is_in_group("interaction_areas"):
		currentInteractable = area
	
func _on_area_exited(body: Node3D, area: Area3D):
	if area == currentInteractable:
		currentInteractable = null

func interaction() -> void:
	if currentInteractable == null:
		return
	
	if Input.is_action_just_pressed("Interact"):
		# Resource type is currently the same as interactble type
		var resourceType = currentInteractable.get_interactable_type()
		var resourceName
		match resourceType:
			ResourceType.WOOD_PLANK:
				resourceName = "wood plank"
			ResourceType.NAILS:
				resourceName = "nails"
			ResourceType.HAMMER:
				resourceName = "hammer"
		
		if inventory.has(resourceType):
			inventory[resourceType] += 1
			var count = inventory[resourceType]
			var message = "Gathered %s. Now have %d" % [resourceName, count]
			messageBoard.push_notification(message)
		else:
			print("Found a \"%s\" (dunno wtf this is)" % resourceName)
			
		currentInteractable.disable()
