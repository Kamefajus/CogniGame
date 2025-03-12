extends Node

@onready var name_input = $VBoxContainer/NameInput
@onready var nickname_input = $VBoxContainer/NickInput
@onready var email_input = $VBoxContainer/EmailInput
@onready var password_input = $VBoxContainer/PasswordInput
@onready var repeat_password_input = $VBoxContainer/RepPasswordInput
@onready var error_label = $VBoxContainer/ErrorLabel
#@onready var db = preload("res://scripts/database.gd").new()

func _ready() -> void:
	Database._ready()

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
		await get_tree().create_timer(1.5).timeout
		get_tree().change_scene_to_file("res://scenes/login_menu.tscn")
	else:
		error_label.text = "Prisijungimo vardas ar el. paštas jau naudojamas"


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/login_menu.tscn")
