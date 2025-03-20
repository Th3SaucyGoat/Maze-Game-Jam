extends CanvasLayer

@onready var notification0 = $Notification0

func push_notification(message: String) -> void:
	notification0.set_message(message)
