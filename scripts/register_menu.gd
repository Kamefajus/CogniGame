extends Node

@onready var name_input = $VBoxContainer/NameInput
@onready var nickname_input = $VBoxContainer/NickInput
@onready var email_input = $VBoxContainer/EmailInput
@onready var password_input = $VBoxContainer/PasswordInput
@onready var repeat_password_input = $VBoxContainer/RepPasswordInput
@onready var error_label = $VBoxContainer/ErrorLabel
#@onready var db = preload("res://scripts/database.gd").new()

func _ready() -> void:
	var fade = get_tree().root.get_node("/root/Control/FadeLayer")
	fade.hard_fade_in()
	Database._ready()
	_add_click_sounds_to_buttons(self)

func _add_click_sounds_to_buttons(node):
	for child in node.get_children():
		if child is Button:
			child.connect("pressed", Callable(AudioManager, "play_click"))
		elif child.get_child_count() > 0:
			_add_click_sounds_to_buttons(child)

func _process(delta: float) -> void:
	pass

func _on_register_button_pressed() -> void:
	var name = name_input.text
	var nickname = nickname_input.text
	var email = email_input.text
	var password = password_input.text
	var repeat_password = repeat_password_input.text

	if name.is_empty() or nickname.is_empty() or email.is_empty() or password.is_empty():
		error_label.text = "Privaloma užpildyti visus laukus."
		return
	if password != repeat_password:
		error_label.text = "Slaptažodžiai nesutampa..."
		return

	if Database.register_user(name, nickname, email, password):
		error_label.text = "Registracija sėkminga! Perkeliama..."
		change_scene("res://scenes/login_menu.tscn")
	else:
		error_label.text = "Prisijungimo vardas ar el. paštas jau naudojamas"


func _on_back_button_pressed() -> void:
	change_scene("res://scenes/login_menu.tscn")

func change_scene(scene_path):
	var fade = get_tree().root.get_node("/root/Control/FadeLayer")
	fade.hard_fade_out()
	fade.connect("faded_out", Callable(self, "_on_fade_done").bind(scene_path), CONNECT_ONE_SHOT)
	
func _on_fade_done(scene_path):
	get_tree().change_scene_to_file(scene_path)
