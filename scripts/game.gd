extends Node2D

@onready var notif_scene = preload("res://scenes/Notif.tscn")
@onready var pause_scene = preload("res://scenes/Pause.tscn")

var play_time := 0.0  # Time in seconds
const MAX_PLAY_TIME := 10  # 1 second for testing
var notif = null
var pause = null

func _ready():
	set_process_input(true)

func _process(delta: float) -> void:
	if pause == null:
		play_time += delta
	if play_time >= MAX_PLAY_TIME and notif == null:
		show_notification()
 
func show_notification() -> void:
	if notif == null:
		notif = notif_scene.instantiate()
		notif.global_position = Vector2(400, 200)
		add_child(notif) 

func _input(ev):
	if Input.is_action_just_pressed("ui_cancel"):
		if pause == null:
			print(pause)
			pause = pause_scene.instantiate()
			get_tree().get_root().add_child(pause)
		elif pause != null and pause.visible == true:
			get_tree().get_root().remove_child(pause)
			pause = null
		

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
