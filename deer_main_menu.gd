extends Node3D

@onready var ani = $TrueAnimationPlayer
@onready var aniTree = $AnimationTree

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#ani.play("Idle_Standing")
	setAniTree(-1.0)
	switchAni()
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func switchAni():
	for i in range(5):
		await get_tree().create_timer(5.0+i).timeout
		get_tree().create_tween().tween_method(setAniTree, -1.0, 1.0, 1.0)
		await get_tree().create_timer(5.0+i).timeout
		get_tree().create_tween().tween_method(setAniTree, 1.0, -1.0, 1.0)
		

func setAniTree(value: float):
		aniTree.set("parameters/blend_position", value)
	
