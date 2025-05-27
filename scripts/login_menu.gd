extends Node

@onready var nickname_input = $VBoxContainer/NicknameInput
@onready var password_input = $VBoxContainer/PasswordInput
@onready var error_label = $VBoxContainer/ErrorLabel
#@onready var db = preload("res://scripts/database.gd").new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var fade_scene
	if 	get_tree().root.get_node_or_null("/root/Control/FadeLayer") == null:
		fade_scene = preload("res://scenes/FadeLayer.tscn").instantiate()
		get_tree().root.add_child.call_deferred(fade_scene)
		await get_tree().create_timer(0.5).timeout
	else:
		fade_scene = get_tree().root.get_node("/root/Control")
	# Paleidžiam testą:
	var fade = fade_scene.get_node("FadeLayer")
	fade.hard_fade_in()
	Database._ready()
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


func _on_login_button_pressed() -> void:
	var nickname = nickname_input.text
	var password = password_input.text

	if Database.verify_login(nickname, password):
		error_label.text = "Prisijungimas sėkmingas"
		change_scene("res://scenes/main_menu.tscn")
	else:
		error_label.text = "Neteisingas prisijungimo vardas arba slaptažodis."


func _on_register_button_pressed() -> void:
	change_scene("res://scenes/register_menu.tscn")


func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_password_reset_button_pressed() -> void:
	change_scene("res://scenes/password_reset_scenes/enter_email_scene.tscn")

func change_scene(scene_path):
	var fade = get_tree().root.get_node("/root/Control/FadeLayer")
	fade.hard_fade_out()
	fade.connect("faded_out", Callable(self, "_on_fade_done").bind(scene_path), CONNECT_ONE_SHOT)
	
func _on_fade_done(scene_path):
	get_tree().change_scene_to_file(scene_path)
