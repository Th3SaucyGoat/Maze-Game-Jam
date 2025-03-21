extends Node3D

@export var objectScene: PackedScene

const ResourceType = preload("res://resource_type.gd").ResourceType

@onready var ui = get_node("../UI")

@onready var Player = get_node("../Player")

var expectedInventory = {
	ResourceType.WOOD_PLANK: 4,
	ResourceType.NAILS: 3,
	ResourceType.HAMMER: 1,
}

var inventory = {
	ResourceType.WOOD_PLANK: 0,
	ResourceType.NAILS: 0,
	ResourceType.HAMMER: 0,
}

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


func houseFound_SpawnInObjects():
	ui.showItemObjective(expectedInventory)
	for i in range(expectedInventory[ResourceType.WOOD_PLANK]):
		var instance = objectScene.instantiate()
		instance.resourceType = ResourceType.WOOD_PLANK
		add_child(instance)
		instance.global_position = spawnPositions.pop_at(randi_range(0,spawnPositions.size()-1)).global_position
	for i in range(expectedInventory[ResourceType.NAILS]):
		var instance = objectScene.instantiate()
		instance.resourceType = instance.ResourceType.NAILS
		add_child(instance)
		instance.global_position = spawnPositions.pop_at(randi_range(0,spawnPositions.size()-1)).global_position
	for i in range(expectedInventory[ResourceType.HAMMER]):
		var instance = objectScene.instantiate()
		instance.resourceType = instance.ResourceType.HAMMER
		add_child(instance)
		instance.global_position = spawnPositions.pop_at(randi_range(0,spawnPositions.size()-1)).global_position
	pass

func collectedObject(type):
	var resourceName
	match type:
		ResourceType.WOOD_PLANK:
			resourceName = "wood plank"
		ResourceType.NAILS:
			resourceName = "nails"
		ResourceType.HAMMER:
			resourceName = "hammer"
			
	if inventory.has(type):
		inventory[type] += 1
	else:
		print("Found a \"%s\" (dunno wtf this is)" % resourceName)
	ui.itemFound(inventory, expectedInventory)


	if inventory[ResourceType.WOOD_PLANK] == expectedInventory[ResourceType.WOOD_PLANK] and inventory[ResourceType.NAILS] == expectedInventory[ResourceType.NAILS] and inventory[ResourceType.HAMMER] == expectedInventory[ResourceType.HAMMER]:
		#gameWon()
		Player.set_objective_to_return_home()
		ui.showReturnHomeObjective()
func gameLost():
	ui.defeat_screen()

func gameWon():
	ui.victory_screen()
	Player.victory_cutscene()
