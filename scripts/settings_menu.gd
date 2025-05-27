extends Control

signal settings_closed
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$MarginContainer/VBoxContainer/Button.connect("pressed", Callable(AudioManager, "play_click"))
	process_mode = Node.PROCESS_MODE_ALWAYS


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_exit_pressed() -> void:
	emit_signal("settings_closed")
	await get_tree().create_timer(0.5).timeout
	queue_free()
	
func _input(ev):
	if Input.is_action_just_pressed("ui_cancel"):
		_on_exit_pressed()

func _on_settings_closed():
	print("Settings menu closed")
	show()
