extends Control

signal settings_closed
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_exit_pressed() -> void:
	emit_signal("settings_closed")
	queue_free()
	
func _input(ev):
	if Input.is_action_just_pressed("ui_cancel"):
		_on_exit_pressed()
