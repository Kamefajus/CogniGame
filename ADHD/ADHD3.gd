extends CanvasLayer

var numbers = [1, 2, 3, 4]
var correct_order = []
var user_order = []

@onready var container = $ButtonsContainer
@onready var result_popup = $ResultPopup
@onready var result_label = $ResultPopup/Label

func _ready():
	await _start_new_round()

func _start_new_round():
	randomize()
	correct_order = numbers.duplicate()
	user_order.clear()

	for child in container.get_children():
		child.queue_free()

	var shuffled_buttons = numbers.duplicate()
	shuffled_buttons.shuffle()

	for number in shuffled_buttons:
		var button = Button.new()
		button.text = str(number)
		button.name = "Button%d" % number
		button.pressed.connect(_on_button_pressed.bind(number))
		container.add_child(button)

	print("Teisinga seka:", correct_order)
	print("Mygtukų tvarka:", shuffled_buttons)

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
			print("🎉 Teisinga seka!")
			_show_result_popup("🎉 Teisinga seka!")
		else:
			print("❌ Neteisinga seka.")
			_show_result_popup("❌ Neteisinga seka.")

		await get_tree().create_timer(3).timeout
		await _start_new_round()

func _show_result_popup(message: String) -> void:
	result_label.text = message
	result_popup.popup_centered()
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
	get_tree().change_scene_to_file("res://ADHD/ADHD2.tscn")


func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://ADHD/ADHD4.tscn")
