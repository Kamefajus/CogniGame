extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Button.connect("pressed", Callable(AudioManager, "play_click"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	SceneTransition.change_scene_slide_animation("res://scenes/main_menu.tscn", true)
