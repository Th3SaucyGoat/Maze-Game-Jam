extends CanvasLayer

const TOTAL_TIME = 2.0;
const FADE_TIME = 1.0;
var timer = TOTAL_TIME;

const ResourceType = preload("res://resource_type.gd").ResourceType

@onready var background = $Background
@onready var victoryText = $Victory
@onready var defeatText = $Defeat
@onready var interactLabel = $InteractLabel

@onready var ItemLabel = $Objective/ItemLabel

enum UIState {
	MAIN_MENU,
	IN_GAME,
	VICTORY,
	DEFEAT,
}

var state = UIState.MAIN_MENU

func _ready() -> void:
	background.modulate.a = 0.0
	victoryText.modulate.a = 0.0
	defeatText.modulate.a = 0.0

func _process(delta: float) -> void:
	match state:
		UIState.IN_GAME:
			return

func defeat_screen() -> void:
	var timer = TOTAL_TIME
	background.visible = true
	defeatText.visible = true
	state = UIState.DEFEAT

func victory_screen() -> void:
	var timer = TOTAL_TIME
	background.visible = true
	victoryText.visible = true
	state = UIState.VICTORY

func itemFound(currentInv, expectedInv):
	ItemLabel.text = str(currentInv[ResourceType.NAILS])+"/"+str(expectedInv[ResourceType.NAILS])+ " Nails\n"+ str(currentInv[ResourceType.WOOD_PLANK])+"/"+str(expectedInv[ResourceType.WOOD_PLANK]) + " Wood Planks\n"+ str(currentInv[ResourceType.HAMMER])+"/"+str(expectedInv[ResourceType.HAMMER])+" Hammers"

func showItemObjective(expectedInv):
	objectiveText.text = "Find Objects"
	ItemLabel.text = "0/"+str(expectedInv[ResourceType.NAILS])+ " Nails\n0/"+str(expectedInv[ResourceType.WOOD_PLANK]) + " Wood Planks\n0/"+str(expectedInv[ResourceType.HAMMER])+" Hammers"

func showReturnHomeObjective():
	ItemLabel.visible = false
	objectiveText.text = "Return home and build the barrier!"

@onready var objectiveText = $Objective
#func set_objective(message: String) -> void:
	#objectiveText.text = "Objective: %s" % message

@onready var notification = $Notification
func push_notification(message: String) -> void:
	notification.set_message(message)



func _on_player_can_interact(canInteract) -> void:
	interactLabel.visible = canInteract
