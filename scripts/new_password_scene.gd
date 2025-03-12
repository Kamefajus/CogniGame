extends Node

@onready var password_input = $VBoxContainer/PasswordInput
@onready var password_2_input = $VBoxContainer/PasswordInput2
@onready var error_label = $VBoxContainer/ErrorLabel

var email = "";

func _ready() -> void:
	Database._ready()


func _on_change_password_button_pressed() -> void:
	var password = password_input.text
	var repeat_password = password_2_input.text
	
	if password.is_empty() or repeat_password.is_empty():
		error_label.text = "Privaloma užpildyti visus laukus."
		return
	if password != repeat_password:
		error_label.text = "Slaptažodžiai nesutampa."
		return
	
	if Database.update_user_password(password, email):
		error_label.text = "Registracija sėkminga! Perkeliama..."
		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file("res://scenes/login_menu.tscn")
	else:
		error_label.text = "Įvyko klaida įrašant pokyčius."


func _on_exit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/password_reset_scenes/enter_email_scene.tscn")


func set_email(new_email: String) -> void:
	email = new_email
	print("Email received: ", email)
