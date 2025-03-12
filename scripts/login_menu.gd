extends Node

@onready var nickname_input = $VBoxContainer/NicknameInput
@onready var password_input = $VBoxContainer/PasswordInput
@onready var error_label = $VBoxContainer/ErrorLabel
#@onready var db = preload("res://scripts/database.gd").new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Database._ready()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_login_button_pressed() -> void:
	var nickname = nickname_input.text
	var password = password_input.text

	if Database.verify_login(nickname, password):
		error_label.text = "Prisijungimas sėkmingas"
		await get_tree().create_timer(1.5).timeout
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	else:
		error_label.text = "Neteisingas prisijungimo vardas arba slaptažodis."


func _on_register_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/register_menu.tscn")


func _on_exit_button_pressed() -> void:
	get_tree().quit()
