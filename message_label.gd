extends Label

const TOTAL_TIME = 2.0 # How long it will display full alpha
const FADE_TIME = 1.0

var fadeTimer = 0.0

func _ready() -> void:
	assert(
		TOTAL_TIME > FADE_TIME, 
		"Total message display time must be greater than the fade time!"
		)

func _process(delta: float) -> void:
	fadeTimer -= delta
	if fadeTimer < FADE_TIME:
		modulate.a = fadeTimer / FADE_TIME

func set_message(message: String) -> void:
	text = message
	fadeTimer = TOTAL_TIME
	modulate.a = 1.0
