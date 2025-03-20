extends Area3D

func _ready() -> void:
	var player = get_tree().get_first_node_in_group("player")
	connect("body_entered", player.on_area_entered.bind(self))
	connect("body_exited", player.on_area_exited.bind(self))
