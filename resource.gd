extends Node3D

const ResourceType = preload("res://resource_type.gd").ResourceType

var woodPlankScene = preload("res://resource_wood_plank.tscn")
var nailsScene = preload("res://resource_nails.tscn")
var hammerScene = preload("res://resource_hammer.tscn")

@export var resourceType = ResourceType.WOOD_PLANK

var turnSpeed = 1.0
var objectInstance

func _ready() -> void:
	match resourceType:
		ResourceType.WOOD_PLANK:
			objectInstance = woodPlankScene.instantiate()
		ResourceType.NAILS:
			objectInstance = nailsScene.instantiate()
		ResourceType.HAMMER:
			objectInstance = hammerScene.instantiate()
	add_child(objectInstance)
	objectInstance.rotate_x(deg_to_rad(30))

func _process(delta: float) -> void:
	objectInstance.rotate_y(turnSpeed*delta)
