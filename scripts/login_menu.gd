extends Node

@onready var nickname_input = $VBoxContainer/NicknameInput
@onready var password_input = $VBoxContainer/PasswordInput
@onready var error_label = $VBoxContainer/ErrorLabel
#@onready var db = preload("res://scripts/database.gd").new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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
		SceneTransition.change_scene("res://scenes/main_menu.tscn")
	else:
		error_label.text = "Neteisingas prisijungimo vardas arba slaptažodis."


func _on_register_button_pressed() -> void:
	SceneTransition.change_scene("res://scenes/register_menu.tscn")


func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_password_reset_button_pressed() -> void:
	SceneTransition.change_scene("res://scenes/password_reset_scenes/enter_email_scene.tscn")
	#var fade = get_tree().root.get_node("/root/Control/FadeLayer")
	#fade.hard_fade_out(0.8)
	#fade.connect("faded_out", Callable(self, "_on_fade_done").bind("res://scenes/password_reset_scenes/enter_email_scene.tscn"), CONNECT_ONE_SHOT)


func _on_fade_done(scene_path):
	get_tree().change_scene_to_file(scene_path)
