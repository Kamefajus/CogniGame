extends Node2D

@onready var ball = $Ball
@onready var target_line = $TargetLine
@onready var stop_button = $StopButton
@onready var score_label = $ScoreLabel

var ball_speed = 200.0
var moving = true
var score = 0

func _ready():
	reset_ball()
	stop_button.pressed.connect(_on_stop_button_pressed)

func _process(delta):
	if moving:
		ball.position.x += ball_speed * delta

func _on_stop_button_pressed():
	if not moving:
		return

	moving = false
	var ball_pos = ball.position
	var target_pos = target_line.position
	var target_size = target_line.size

	# Apskaičiuojame kvadrato ribas
	var left = target_pos.x
	var right = target_pos.x + target_size.x
	var top = target_pos.y
	var bottom = target_pos.y + target_size.y

	# Tikriname, ar kamuolio pozicija patenka į kvadratą
	var is_inside = ball_pos.x >= left and ball_pos.x <= right and \
					ball_pos.y >= top and ball_pos.y <= bottom

	if is_inside:
		score += 10
		score_label.text = "Taškai: %d (Puikiai!)" % score
	else:
		# Jei nepataikė – skaičiuojame artimiausią atstumą iki centro
		var target_center = target_pos + target_size / 2
		var distance = ball_pos.distance_to(target_center)

		if distance <= 50:
			score += 5
			score_label.text = "Taškai: %d (Beveik!)" % score
		elif distance <= 100:
			score += 2
			score_label.text = "Taškai: %d (Tolokai...)" % score
		else:
			score -= 5
			score_label.text = "Taškai: %d (Prašovei!)" % score

	await get_tree().create_timer(1.0).timeout
	reset_ball()
	moving = true

func reset_ball():
	ball.position = Vector2(0, 285)  # Y turi sutapti su kamuolio centru
func on_tab_entered():
	set_process(true)
	set_physics_process(true)
	visible = true
	# Resume timers, animations, etc.

func on_tab_exited():
	set_process(false)
	set_physics_process(false)
	visible = false


func _on_button1_pressed() -> void:
	get_tree().change_scene_to_file("res://ADHD/ADHD6.tscn")


func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://ADHD/ADHD8.tscn")
