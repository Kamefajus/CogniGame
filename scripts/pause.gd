extends Control

@onready var settings_scene = preload("res://scenes/settings_menu.tscn")
var settings = null

func _ready():
	_add_click_sounds_to_buttons(self)

func _on_back_pressed():
	queue_free()  # This safely removes the pause scene from the tree

func _add_click_sounds_to_buttons(node):
	for child in node.get_children():
		if child is Button:
			child.connect("pressed", Callable(AudioManager, "play_click"))
		elif child.get_child_count() > 0:
			_add_click_sounds_to_buttons(child)

func _on_settings_pressed():
	if settings == null:
		settings = settings_scene.instantiate()
		settings.connect("settings_closed", Callable(self, "_on_settings_closed"))
		get_tree().get_root().add_child(settings)
		hide()

func _on_exit_pressed():
	get_tree().quit()  # Exits the game

func _on_settings_closed():
	settings = null
	show()  # Show pause menu again
