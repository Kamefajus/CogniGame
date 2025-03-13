extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _pressed() -> void:
	var notif = get_parent() # Find the notification in the scene
	if notif:
		notif.hide()  # Close only the notification

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
