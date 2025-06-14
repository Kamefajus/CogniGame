extends Control

var correct_order = []
var current_index = 0
var completed_correctly := false

# Fixed positions for each button
var fixed_positions = [
	Vector2(163, 510),  # TextureButton1
	Vector2(336, 465),  # TextureButton2
	Vector2(190, 155),  # TextureButton3
	Vector2(614, 154)   # TextureButton4
]

@onready var result_label = $ResultLabel

func _ready():
	correct_order = [
		$TextureButton1,
		$TextureButton2,
		$TextureButton3,
		$TextureButton4
	]
	set_fixed_button_positions()

	# Connect button pressed signals
	for button in correct_order:
		button.pressed.connect(_on_button_pressed.bind(button))

	result_label.text = ""
	result_label.visible = false

	print("🟢 Žaidimas pradėtas! Paspausk mygtukus nuo mažiausio iki didžiausio.")

func set_fixed_button_positions():
	for i in range(correct_order.size()):
		correct_order[i].position = fixed_positions[i]

func _on_button_pressed(button):
	var expected_button = correct_order[current_index]
	if button == expected_button:
		print("✅ Teisingas mygtukas paspaustas! Indeksas:", current_index)
		button.disabled = true
		current_index += 1
		result_label.visible = false

		if current_index >= correct_order.size():
			show_success()
	else:
		print("❌ Neteisingas mygtukas! Tikėtasi:", expected_button.name, "– Bet paspausta:", button.name)
		show_failure()

func show_success():
	result_label.text = "✅ Teisingai!"
	result_label.visible = true
	print("Teisingai!")
	emit_signal("task_completed", true)

func show_failure():
	result_label.text = "❌ Neteisingai!"
	result_label.visible = true
	emit_signal("task_completed", false)
	reset_game()

func reset_game():
	# Enable all buttons and reset state
	for button in correct_order:
		button.disabled = false
	current_index = 0

signal task_completed(correct: bool)

func is_correct() -> bool:
	return result_label.text == "✅ Teisingai!"  # or use a variable like `completed_correctly`
