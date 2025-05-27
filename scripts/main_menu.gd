extends Control

@onready var settings_scene = preload("res://scenes/settings_menu.tscn")
var settings = null
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_add_click_sounds_to_buttons(self)

func _add_click_sounds_to_buttons(node):
	for child in node.get_children():
		if child is Button:
			child.connect("pressed", Callable(AudioManager, "play_click"))
		elif child.get_child_count() > 0:
			_add_click_sounds_to_buttons(child)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_pressed() -> void:

	SceneTransition.change_scene_slide_animation("res://scenes/Game.tscn", false)


func _on_button_2_pressed():
	if settings == null:
		SceneTransition.slide_animation_in_parts(1, false)
		await get_tree().create_timer(0.5).timeout
		settings = settings_scene.instantiate()
		settings.connect("settings_closed", Callable(self, "_on_settings_closed"))
		get_tree().get_root().add_child(settings)
		hide()
		SceneTransition.slide_animation_in_parts(2, false)

func _on_exit_pressed():
	get_tree().quit()

func _on_settings_closed():
	SceneTransition.slide_animation_in_parts(1, true)
	await get_tree().create_timer(0.5).timeout
	show()
	settings = null
	show() 
	
func change_scene(scene_path):
	var fade = get_tree().root.get_node("/root/Control/FadeLayer")
	fade.hard_fade_out()
	fade.connect("faded_out", Callable(self, "_on_fade_done").bind(scene_path), CONNECT_ONE_SHOT)
	
func _on_fade_done(scene_path):
	get_tree().change_scene_to_file(scene_path)
	SceneTransition.slide_animation_in_parts(2, true)


func _on_button_4_pressed() -> void:
	SceneTransition.change_scene("res://scenes/market.tscn")
