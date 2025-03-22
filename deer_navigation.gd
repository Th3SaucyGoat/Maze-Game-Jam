extends Node3D

@onready var player = get_node("../Player")
@onready var navagent = $NavigationAgent3D
@onready var anitree = $AnimationTree
@onready var ani = $TrueAnimationPlayer
@onready var audio = $AudioStreamPlayer3D
@onready var growlTimer = $GrowlTimer

@export var growlSounds: Array

var timePerGrowl: Array = [10.0, 30.0]

const JUMPSCARE_DISTANCE = 3.0
const START_SIZE = 3.0
const STANDUP_SIZE = 5.0
const MAX_SIZE = 10.0
const GROWTH_SPEED = 0.05 # Scale factors per second

var state = MonsterState.WANDERING
var speed = 1.0
var standupBlending = 0.0
var size = START_SIZE

enum MonsterState {
	WANDERING,
	FOLLOWING,
	JUMPSCARE,
}

func _ready() -> void:
	growlTimer.start(randf_range(timePerGrowl[0], timePerGrowl[1]))
	ani.get_animation("Walk_normal").loop_mode = Animation.LOOP_LINEAR
	ani.get_animation("Walk_Standing").loop_mode = Animation.LOOP_LINEAR

func _physics_process(delta: float) -> void:
	
	var motionPaused = false
	
	# Grow the monster
	if size < MAX_SIZE:
		size += GROWTH_SPEED * delta
	
	if size > STANDUP_SIZE and standupBlending < 1.0:
			standupBlending += 0.1
			anitree.set("parameters/Blend2/blend_amount", standupBlending)
	
	scale = Vector3(size, size, size)
	
	match state:
		MonsterState.WANDERING:
			do_wandering(delta)
		MonsterState.FOLLOWING:
			do_following(delta)
		MonsterState.JUMPSCARE:
			do_jumpscare(delta)

func move_to_target(delta: float) -> void:
	
	# Move along the navagent's selected path toward the player
	var next_position = navagent.get_next_path_position()
	var move_delta = speed * size * delta
	global_transform.origin = global_transform.origin.move_toward(next_position, move_delta)
	
	# Rotate towards the target
	var direction = (next_position - global_transform.origin).normalized()
	var forward = global_transform.basis.z.normalized()
	var angle = forward.signed_angle_to(direction, Vector3.UP)
	var step = 5.0 * angle * delta
	var rotation_amount = clamp(angle, -step, step)
	var original_origin = transform.origin
	transform.origin = Vector3.ZERO
	transform = transform.rotated(Vector3.UP, rotation_amount)
	transform.origin = original_origin
	
func check_sightline():
	var rayQuery = PhysicsRayQueryParameters3D.new()
	rayQuery.from = global_transform.origin + 10.0 * size * Vector3.UP
	rayQuery.to = player.global_transform.origin
	rayQuery.collision_mask = 3
	
	var result = get_world_3d().direct_space_state.intersect_ray(rayQuery)
	if result:
		if result.collider == player:
			state = MonsterState.FOLLOWING
		else:
			state = MonsterState.WANDERING
	
func do_wandering(delta: float):
	
	if navagent.is_navigation_finished():
		var wanderx = randf_range(-100.0, 100.0)
		var wandery = transform.origin.y
		var wanderz = randf_range(-100.0, 100.0)
		navagent.set_target_position(Vector3(wanderx, wandery, wanderz))
	
	move_to_target(delta)
	check_sightline()
	
func do_following(delta: float):
	var playerpos = player.global_transform.origin
	navagent.set_target_position(playerpos)
	
	if navagent.is_navigation_finished():
		return
		
	move_to_target(delta)
	check_sightline()
	
	if playerpos.distance_to(global_transform.origin) < JUMPSCARE_DISTANCE:
		player.jumpscare_cutscene(self)
		state = MonsterState.JUMPSCARE

func do_jumpscare(_delta: float):
	ani.play("Attack_Standing")


func _on_growl_timer_timeout() -> void:
	audio.stream = growlSounds.pick_random()
	audio.play(0)
	growlTimer.start(randf_range(timePerGrowl[0], timePerGrowl[1]))
