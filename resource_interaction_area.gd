extends Area3D

@export var interactableType = "WoodPlank"

func _ready() -> void:
	add_to_group("interaction_areas")
	
	var player = get_tree().get_first_node_in_group("player")
	connect("body_entered", player._on_area_entered.bind(self))
	connect("body_exited", player._on_area_exited.bind(self))

func get_interactable_type() -> String:
	return interactableType
