extends AudioStreamPlayer

@export var randomNoises: Array
@onready var randNoiseSource = $RandomNoise
@onready var randPos = $"Positions for random noises"
@onready var timer = $Timer

var timeElasped: float = 0
var durationTillNoise: float = 15.0
var currentDurationTillNoise = 15.0
var randomVariation:float = 2.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#timeElasped += delta
	#if timeElasped > currentDurationTillNoise:
		#randNoiseSource.stream = randomNoises.pick_random()
		#randNoiseSource.global_position = randPos.get_children().pick_random().global_position
		#randNoiseSource.play(0)
		#timeElasped = 0
		#currentDurationTillNoise = randf_range(durationTillNoise/randomVariation, durationTillNoise*randomVariation)
		#print(currentDurationTillNoise)
