extends Node3D

@onready var player = get_node("../Player")
@onready var navagent = $NavigationAgent3D

const JUMPSCARE_DISTANCE = 3.0
var state = MonsterState.WANDERING
var speed = 3.0

enum MonsterState {
	WANDERING,
	FOLLOWING,
	JUMPSCARE,
}

func _physics_process(delta: float) -> void:
	match state:
		MonsterState.WANDERING:
			do_wandering(delta)
		MonsterState.FOLLOWING:
			do_following(delta)
		MonsterState.JUMPSCARE:
			do_jumpscare(delta)

func do_wandering(delta: float):
	# TODO
	state = MonsterState.FOLLOWING
	
func do_following(delta: float):
	var playerpos = player.global_transform.origin
	navagent.set_target_position(playerpos)
	
	if navagent.is_navigation_finished():
		return
	
	# Move along the navagent's selected path toward the player
	var next_position = navagent.get_next_path_position()
	var move_delta = speed * delta
	global_transform.origin = global_transform.origin.move_toward(next_position, move_delta)
	
	# Rotate towards the player
	var direction = (next_position - global_transform.origin).normalized()
	var forward = global_transform.basis.z.normalized()
	var angle = forward.signed_angle_to(direction, Vector3.UP)
	var step = 5.0 * angle * delta
	var rotation_amount = clamp(angle, -step, step)
	var original_origin = transform.origin
	transform.origin = Vector3.ZERO
	transform = transform.rotated(Vector3.UP, rotation_amount)
	transform.origin = original_origin
	
	if playerpos.distance_to(global_transform.origin) < JUMPSCARE_DISTANCE:
		player.jumpscare_cutscene(self)
		state = MonsterState.JUMPSCARE

func do_jumpscare(delta: float):
	pass
