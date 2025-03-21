extends Node3D

const ResourceType = preload("res://resource_type.gd").ResourceType

var woodPlankScene = preload("res://resource_wood_plank.tscn")
var nailsScene = preload("res://resource_nails.tscn")
var hammerScene = preload("res://resource_hammer.tscn")

@export var resourceType = ResourceType.WOOD_PLANK

var turnSpeed = 1.0

func _ready() -> void:
	var instance
	match resourceType:
		ResourceType.WOOD_PLANK:
			instance = woodPlankScene.instantiate()
		ResourceType.NAILS:
			instance = nailsScene.instantiate()
		ResourceType.HAMMER:
			instance = hammerScene.instantiate()
	add_child(instance)
	rotate_x(deg_to_rad(30))

func _process(delta: float) -> void:
	rotate_y(turnSpeed*delta)
