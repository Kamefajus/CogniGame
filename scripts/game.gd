# game.gd
extends Node2D

@onready var notif_scene = preload("res://scenes/Notif.tscn")
@onready var pause_scene = preload("res://scenes/Pause.tscn")
@onready var ai_scene    : PackedScene = preload("res://scenes/ai_agent.tscn")

var play_time := 0.0
const MAX_PLAY_TIME := 10
var notif = null
var pause = null

func _ready():
	set_process_input(true)

func _process(delta):
	if pause == null:
		play_time += delta
	if play_time >= MAX_PLAY_TIME and notif == null:
		show_notification()

func show_notification():
	notif = notif_scene.instantiate()
	notif.global_position = Vector2(400,200)
	add_child(notif)

func _input(ev):
	if Input.is_action_just_pressed("ui_cancel"):
		if pause == null:
			pause = pause_scene.instantiate()
			get_tree().get_root().add_child(pause)
		else:
			get_tree().get_root().remove_child(pause)
			pause = null

func _on_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_win_ai_button_pressed():
	var old = get_tree().current_scene
	var ai = ai_scene.instantiate()
	get_tree().get_root().add_child(ai)
	get_tree().set_current_scene(ai)
	old.queue_free()
	ai.show_success_screen("Žaidėjas laimėjo, pagirk ir paskatink jį!")

func _on_lose_ai_button_pressed():
	var old = get_tree().current_scene
	var ai = ai_scene.instantiate()
	get_tree().get_root().add_child(ai)
	get_tree().set_current_scene(ai)
	old.queue_free()
	ai.show_failure_screen("Žaidėjas pralaimėjo, paskatink jį neprarasti pasitikėjimo savimi.")
