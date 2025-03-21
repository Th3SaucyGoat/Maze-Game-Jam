extends Node3D

@export var objectScene: PackedScene

const ResourceType = preload("res://resource_type.gd").ResourceType

var numOfWoodPlanks = 4
var numOfNails = 3
var numOfHammer = 1

var spawnPositions: Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawnPositions = get_children()
	#var h = house.instantiate()
	#add_child(h)
	#h.global_position = Vector3(0, 0, 0)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func spawnInObjects():
	for i in range(numOfWoodPlanks):
		var instance = objectScene.instantiate()
		instance.resourceType = ResourceType.WOOD_PLANK
		add_child(instance)
		instance.global_position = spawnPositions.pop_at(randi_range(0,spawnPositions.size()-1)).global_position
	for i in range(numOfNails):
		var instance = objectScene.instantiate()
		instance.resourceType = instance.ResourceType.NAILS
		add_child(instance)
		instance.global_position = spawnPositions.pop_at(randi_range(0,spawnPositions.size()-1)).global_position
	for i in range(numOfHammer):
		var instance = objectScene.instantiate()
		instance.resourceType = instance.ResourceType.HAMMER
		add_child(instance)
		instance.global_position = spawnPositions.pop_at(randi_range(0,spawnPositions.size()-1)).global_position
	pass
