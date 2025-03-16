extends Area3D

const ResourceType = preload("res://resource_type.gd").ResourceType

func _ready() -> void:
	add_to_group("interaction_areas")
	
	var player = get_tree().get_first_node_in_group("player")
	connect("body_entered", player._on_area_entered.bind(self))
	connect("body_exited", player._on_area_exited.bind(self))

# Right now interactable type is the same as the resource type
# Any new interactables may need to change this
func get_interactable_type() -> ResourceType:
	var parent = get_parent()
	if parent:
		return parent.resourceType
	
	push_error("Resource must have a type!")
	return ResourceType.WOOD_PLANK
