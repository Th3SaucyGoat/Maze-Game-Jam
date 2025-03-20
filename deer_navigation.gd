extends Node3D

@onready var player = get_node("../Player")
@onready var navagent = $NavigationAgent3D

var speed = 3.0

func _physics_process(delta: float) -> void:
	var playerpos = player.transform.origin
	navagent.set_target_position(playerpos)
	
	if navagent.is_navigation_finished():
		return
	
	var next_position = navagent.get_next_path_position()
	var move_delta = speed * delta
	transform.origin = transform.origin.move_toward(next_position, move_delta)
	
	var look_position = Vector3(playerpos.x, transform.origin.y, playerpos.z)
	look_at(look_position)
