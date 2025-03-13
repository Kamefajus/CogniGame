extends Node

@onready var error_label = $VBoxContainer/ErrorLabel
@onready var email_input = $VBoxContainer/EmailInput

func _ready() -> void:
	Database._ready()


func _on_send_code_button_pressed() -> void:
	var email = email_input.text
	
	if email.is_empty():
		error_label.text = "Privaloma užpildyti el. pašto lauką."
		return
	if !Database.verify_email(email):
		error_label.text = "Nėra tokio vartorojo arba padaryta klaida užpildant lauką."
		return
	
	var nextscene = load("res://scenes/password_reset_scenes/password_code_scene.tscn").instantiate()
	nextscene.set_email(email)
	get_tree().current_scene.get_parent().add_child(nextscene)
	get_tree().current_scene.queue_free()


func _on_exit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/login_menu.tscn")
