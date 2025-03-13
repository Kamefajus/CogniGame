extends Node2D

@onready var notif_scene = preload("res://scenes/Notif.tscn")

var play_time := 0.0  # Time in seconds
const MAX_PLAY_TIME := 10  # 1 second for testing
var notif = null

func _process(delta: float) -> void:
	play_time += delta
	if play_time >= MAX_PLAY_TIME and notif == null:
		show_notification()
 
func show_notification() -> void:
	if notif == null:
		notif = notif_scene.instantiate()
		notif.global_position = Vector2(400, 200)
		add_child(notif) 



func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
