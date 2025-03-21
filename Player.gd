extends CharacterBody3D

const ResourceType = preload("res://resource_type.gd").ResourceType

@onready var head = $Head
@onready var camera = $Head/Camera
@onready var audio = $Audio
@onready var flashLight = $Head/Flashlight

@onready var cottage = get_node("../House")

@onready var ui = get_node("../UI")
@onready var gameManager = get_node("../GameManager")

@export var footstepClips: Array

var currentSpeed

const SPEED = 500.0
const SPRINTSPEED = 900.0
const JUMP_VELOCITY = 8.0
const LOOK_SENSITIVITY = .003

var currentInteractable: Area3D = null
var inventory = {
	ResourceType.WOOD_PLANK: 0,
	ResourceType.NAILS: 0,
	ResourceType.HAMMER: 0,
}

var state = PlayerState.CONTROLLABLE
var objective_stage = ObjectiveStage.FIND_HOUSE

enum PlayerState {
	CONTROLLABLE,
	JUMPSCARE_CUTSCENE,
	VICTORY_CUTSCENE,
}

enum ObjectiveStage {
	FIND_HOUSE,
	COLLECT_RESOURCES,
	RETURN_HOME,
}

var timeElasped: float = 0.0
var initialTimeTillFootstep: float = 1.0
var currentTimeTillFootstep: float = 1.0
var spintBonus: float = 1.4
var randomVariation: float = .1

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if state != PlayerState.CONTROLLABLE:
		return
	
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x *LOOK_SENSITIVITY)
		camera.rotate_x(-event.relative.y*LOOK_SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(60))
		flashLight.rotation.x = camera.rotation.x
	if Input.is_action_just_pressed("ToggleFlashlight"):
		flashLight.visible = false if flashLight.visible  else true

func _physics_process(delta: float) -> void:
	match state:
		PlayerState.CONTROLLABLE:
			movement(delta)
		PlayerState.VICTORY_CUTSCENE:
			victory_camera_pan(delta)

func _process(delta: float) -> void:
	interaction()

func on_area_entered(body: Node3D, area: Area3D):
	
	if body != self:
		return
	
	if area.is_in_group("interaction_areas"):
		currentInteractable = area
		return
		
	if objective_stage == ObjectiveStage.FIND_HOUSE:
		if area.is_in_group("home"):
			objective_stage = ObjectiveStage.COLLECT_RESOURCES
			ui.set_objective("Collect barrier materials (X remain)")
			gameManager.spawnInObjects()
	
func on_area_exited(body: Node3D, area: Area3D):
	if area == currentInteractable:
		currentInteractable = null

func movement(delta: float) -> void:
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
		velocity.x = direction.x * currentSpeed*delta
		velocity.z = direction.z * currentSpeed*delta
		timeElasped += delta if currentSpeed == SPEED else delta*spintBonus
		if timeElasped > currentTimeTillFootstep:
			audio.stream = footstepClips.pick_random()
			audio.play(0)
			timeElasped = 0
			currentTimeTillFootstep =  randf_range(initialTimeTillFootstep-randomVariation, initialTimeTillFootstep+randomVariation)
	else:
		velocity.x = move_toward(velocity.x, 0, currentSpeed*delta)
		velocity.z = move_toward(velocity.z, 0, currentSpeed*delta)

	move_and_slide()
	

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
			ui.push_notification(message)
			victory_cutscene()
		else:
			print("Found a \"%s\" (dunno wtf this is)" % resourceName)
			
		currentInteractable.disable()

var victory_camera_position
func victory_camera_pan(delta: float):
	var temp: Vector3 = victory_camera_position - cottage.transform.origin
	temp = temp.rotated(Vector3.UP, -0.1 * delta)
	temp += cottage.transform.origin
	victory_camera_position = temp
	camera.look_at_from_position(
		victory_camera_position, 
		cottage.transform.origin, Vector3.UP
		)

func jumpscare_cutscene(deer: Node3D):
	state = PlayerState.JUMPSCARE_CUTSCENE
	ui.defeat_screen()

func victory_cutscene():
	state = PlayerState.VICTORY_CUTSCENE
	ui.victory_screen()
	
	victory_camera_position = cottage.transform.origin 
	victory_camera_position += 20.0 * Vector3.UP 
	victory_camera_position += 40.0 * Vector3.BACK
