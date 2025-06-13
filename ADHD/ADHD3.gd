extends CanvasLayer

var numbers = [1, 2, 3, 4]
var correct_order = []
var user_order = []

@onready var container = $ButtonsContainer
@onready var result_label = $ResultLabel  # Make sure you have a Label node named ResultLabel

func _ready():
	result_label.text = ""
	result_label.visible = false
	await _start_new_round()

func _start_new_round():
	randomize()
	correct_order = numbers.duplicate()
	user_order.clear()
	result_label.visible = false  # Hide result label at the start of each round

	for child in container.get_children():
		child.queue_free()

	var shuffled_buttons = numbers.duplicate()
	shuffled_buttons.shuffle()

	for number in shuffled_buttons:
		var button = Button.new()
		button.text = str(number)
		button.name = "Button%d" % number
		button.custom_minimum_size = Vector2(60, 60)  # Set minimum size here
		button.pressed.connect(_on_button_pressed.bind(number))
		container.add_child(button)

func _on_button_pressed(number):
	if number in user_order:
		return

	user_order.append(number)
	print("Paspausta:", number)
	print("Dabartinė seka:", user_order)

	var button = container.get_node_or_null("Button%d" % number)
	if button:
		button.disabled = true
	else:
		print("Mygtukas nerastas:", "Button%d" % number)

	if user_order.size() == correct_order.size():
		print("Tikriname seką:")
		print("Vartotojo:", user_order)
		print("Teisinga:", correct_order)

		if user_order == correct_order:
			print("✅ Teisinga seka!")
			_show_result_label("✅ Teisinga seka!")
			emit_signal("task_completed", true)
		else:
			print("❌ Neteisinga seka!")
			_show_result_label("❌ Neteisinga seka.")
			emit_signal("task_completed", false)

		await get_tree().create_timer(3).timeout
		await _start_new_round()

func _show_result_label(message: String) -> void:
	result_label.text = message
	result_label.visible = true
	
signal task_completed(correct: bool)

func is_correct() -> bool:
	return result_label.text == "✅ Teisinga seka!"
