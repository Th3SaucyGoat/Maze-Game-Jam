extends CanvasLayer

const TOTAL_TIME = 2.0;
const FADE_TIME = 1.0;
var timer = TOTAL_TIME;

@onready var background = $Background
@onready var victoryText = $Victory
@onready var defeatText = $Defeat

var victory = false
var defeat = false

func _ready() -> void:
	background.modulate.a = 0.0
	victoryText.modulate.a = 0.0
	defeatText.modulate.a = 0.0

func _process(delta: float) -> void:
	if victory or defeat:
		timer -= delta
		
	if timer < FADE_TIME:
		var amount = (FADE_TIME - timer) / FADE_TIME
		background.modulate.a = amount
		if victory:
			victoryText.modulate.a = amount
		if defeat:
			defeatText.modulate.a = amount

func defeat_screen() -> void:
	var timer = TOTAL_TIME
	defeat = true

func victory_screen() -> void:
	var timer = TOTAL_TIME
	victory = true
