extends Control

@onready var buttons = [
	$ColorButtonRed,
	$ColorButtonBlue,
	$ColorButtonGreen,
	$ColorButtonYellow
]
@onready var info_label = $InfoLabel

var sequence = []
var user_input = []
var sequence_length = 4
var showing_sequence = false
var restarting = false

func _ready():
	for i in range(buttons.size()):
		buttons[i].pressed.connect(_on_button_pressed.bind(i))
	start_game(true)  # Start with a new sequence

func start_game(generate_new: bool = false):
	if restarting:
		return
	restarting = true
	user_input.clear()

	if generate_new:
		generate_sequence()

	showing_sequence = true
	await show_sequence()
	showing_sequence = false
	restarting = false

func generate_sequence():
	sequence.clear()
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	for i in range(sequence_length):
		sequence.append(rng.randi_range(0, buttons.size() - 1))
	print("Sugeneruota seka: ", sequence)

func _on_button_pressed(index):
	if showing_sequence or restarting:
		return

	user_input.append(index)
	await flash_button(index)

	if user_input[user_input.size() - 1] != sequence[user_input.size() - 1]:
		info_label.text = "❌ Neteisingai! Bandyk dar kartą."
		emit_signal("task_completed", false)
		restarting = true
		await get_tree().create_timer(2.0).timeout
		start_game(true)
		return

	if user_input.size() == sequence_length:
		info_label.text = "✅ Teisingai!"
		emit_signal("task_completed", true)
		restarting = true
		await get_tree().create_timer(2.0).timeout
		start_game(false)

func flash_button(index):
	var btn = buttons[index]
	var tween = get_tree().create_tween()

	# Animate scale up to 1.2, then back to 1.0
	tween.tween_property(btn, "scale", Vector2(1.2, 1.2), 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(btn, "scale", Vector2(1, 1), 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	await tween.finished

func show_sequence():
	for index in sequence:
		await flash_button(index)
		await get_tree().create_timer(0.3).timeout

signal task_completed(correct: bool)

func is_correct() -> bool:
	return info_label.text == "✅ Teisingai!"  # or use a variable like `completed_correctly`
