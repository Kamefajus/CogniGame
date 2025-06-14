extends Node2D

@onready var ball = $Ball
@onready var target_line = $TargetLine
@onready var stop_button = $StopButton
@onready var score_label = $ScoreLabel
@onready var result_label = $Result_Label  # Make sure this exists

var ball_speed = 200.0
var moving = true
var game_won = false  # New flag to stop ball permanently when won
var score = 0

func _ready():
	reset_ball()
	stop_button.pressed.connect(_on_stop_button_pressed)
	result_label.visible = false

func _process(delta):
	if moving and not game_won:
		ball.position.x += ball_speed * delta

func _on_stop_button_pressed():
	if not moving or game_won:
		return

	moving = false
	var ball_pos = ball.position
	var target_pos = target_line.position
	var target_size = target_line.size

	var left = target_pos.x
	var right = target_pos.x + target_size.x
	var top = target_pos.y
	var bottom = target_pos.y + target_size.y

	var is_inside = ball_pos.x >= left and ball_pos.x <= right and \
					ball_pos.y >= top and ball_pos.y <= bottom

	if is_inside:
		score += 10
		score_label.text = "Taškai: %d (Puikiai!)" % score
	else:
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

	if score >= 20:
		result_label.text = "✅ Teisingai"
		result_label.visible = true
		game_won = true  # Stop ball permanently here
		emit_signal("task_completed", true)
	elif score <= -20:
		result_label.text = "❌ Neteisingai! Bandyk dar kartą"
		emit_signal("task_completed", false)
		result_label.visible = true
	else:
		result_label.visible = false

	if not game_won:
		await get_tree().create_timer(1.0).timeout
		reset_ball()
		moving = true

func reset_ball():
	ball.position = Vector2(0, 285)
	
signal task_completed(correct: bool)

func is_correct() -> bool:
	return result_label.text == "✅ Teisingai!"  # or use a variable like `completed_correctly`
