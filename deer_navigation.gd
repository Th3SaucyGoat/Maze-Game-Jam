extends Node3D

@onready var player = get_node("../Player")
@onready var navagent = $NavigationAgent3D
@onready var anitree = $AnimationTree
@onready var ani = $TrueAnimationPlayer
@onready var audio = $Growl
@onready var footstepSrc = $Footsteps
@onready var footstepTimer = $FootstepTimer
@onready var growlTimer = $GrowlTimer
@onready var skeleton = $Deer/Skeleton3D
@onready var jumpscareInterpolationPos = $HeadPosInterpolation
@onready var jawUp = $JawUp
@onready var jawDown = $JawDown

@export var growlSounds: Array
@export var jumpscareSound: AudioStream
var jumpscareVol: float = -8.0

var timePerStep: float = .7
var timePerGrowl: Array = [10.0, 30.0]

const JUMPSCARE_DISTANCE = 3.0
const START_SIZE = 2.0
const STANDUP_SIZE = 4.0
const MAX_SIZE = 6.0
const GROWTH_SPEED = 0.001 # Scale factors per second

var state = MonsterState.WANDERING
var speed = 1.2
var standupBlending = 0.0
var size = START_SIZE

enum MonsterState {
	WANDERING,
	FOLLOWING,
	JUMPSCARE,
}

var headLookBone
var downJawBoneIndex
var upJawBoneIndex

func _ready() -> void:
	growlTimer.start(randf_range(timePerGrowl[0], timePerGrowl[1]))
	footstepTimer.start(timePerStep)
	ani.get_animation("Walk_normal").loop_mode = Animation.LOOP_LINEAR
	ani.get_animation("Walk_Standing").loop_mode = Animation.LOOP_LINEAR
	headLookBone = skeleton.find_bone("Bone.006")
	upJawBoneIndex = skeleton.find_bone("Bone.007")
	downJawBoneIndex = skeleton.find_bone("Bone.008")

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

var downJawPose:Transform3D
var upJawPose: Transform3D
func do_following(delta: float):
	var playerpos = player.global_transform.origin
	navagent.set_target_position(playerpos)
	
	if navagent.is_navigation_finished():
		return
		
	move_to_target(delta)
	check_sightline()
	
	
	if playerpos.distance_to(global_transform.origin) < JUMPSCARE_DISTANCE:
		state = MonsterState.JUMPSCARE
		var bone_pose: Transform3D = skeleton.get_bone_global_pose(headLookBone)
		var theCam = player.jumpscare_cutscene()
		theCam.global_position = get_node("CamPosForJumpscare").global_position
		theCam.look_at(get_node("CamLook").global_position)
		var upMouthBone: Transform3D = skeleton.get_bone_global_pose(headLookBone)
		upJawPose = skeleton.get_bone_global_pose(upJawBoneIndex)
		downJawPose = skeleton.get_bone_global_pose(downJawBoneIndex)
		jawUp.transform = upJawPose
		jawUp.global_position += Vector3(0,.1,0)
		jawDown.transform = downJawPose
		jawDown.global_position += Vector3(0,-.15,0)
		skeleton.set_bone_global_pose_override(upJawBoneIndex, jawUp.transform,1.0, true)
		skeleton.set_bone_global_pose_override(downJawBoneIndex, jawDown.transform,1.0, true)
		#bone_pose = bone_pose.looking_at(theCam.global_position)
		jumpscareInterpolationPos.transform = bone_pose
		skeleton.set_bone_global_pose_override(headLookBone, jumpscareInterpolationPos.transform,1.0, true)
		growlTimer.stop()
		footstepTimer.stop()
		audio.stream = jumpscareSound
		audio.volume_db = jumpscareVol
		audio.play(0)
		interpolateHead()

func interpolateHead():
	var tween = create_tween()
	var camPos = get_node("CamPosForJumpscare")
	tween.tween_method(set_head_pos, jumpscareInterpolationPos.global_position, camPos.global_position, 1.0).set_delay(2.0)
	#skeleton.set_bone_global_pose_override(headLookBone, camPos.transform,1.0, true)
	#pass

func set_head_pos(pos:Vector3):
	jumpscareInterpolationPos.global_position = pos
	skeleton.set_bone_global_pose_override(headLookBone, jumpscareInterpolationPos.transform,1.0, true)
	jawUp.global_position.x = pos.x
	jawUp.global_position.z = pos.z
	jawDown.global_position.x = pos.x
	jawDown.global_position.z = pos.z 
	skeleton.set_bone_global_pose_override(upJawBoneIndex, jawUp.transform,1.0, true)
	skeleton.set_bone_global_pose_override(downJawBoneIndex, jawDown.transform,1.0, true)
	#skeleton.set_bone_global_pose_override(upJawBoneIndex, jumpscareInterpolationPos.transform,1.0, true)
	#skeleton.set_bone_global_pose_override(downJawBoneIndex, jumpscareInterpolationPos.transform,1.0, true)
		

func do_jumpscare(_delta: float):
	pass


func _on_growl_timer_timeout() -> void:
	audio.stream = growlSounds.pick_random()
	audio.play(0)
	growlTimer.start(randf_range(timePerGrowl[0], timePerGrowl[1]))


func _on_footstep_timer_timeout() -> void:
	footstepSrc.play(0)
	footstepTimer.start(timePerStep)
	pass # Replace with function body.
