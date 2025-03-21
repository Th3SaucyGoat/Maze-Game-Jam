extends CanvasLayer

const TOTAL_TIME = 2.0;
const FADE_TIME = 1.0;
var timer = TOTAL_TIME;

@onready var background = $Background
@onready var victoryText = $Victory
@onready var defeatText = $Defeat

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

@onready var objectiveText = $Objective
func set_objective(message: String) -> void:
	objectiveText.text = "Objective: %s" % message

@onready var notification = $Notification
func push_notification(message: String) -> void:
	notification.set_message(message)
