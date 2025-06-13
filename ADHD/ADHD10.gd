extends Node2D

@onready var number_label = $NumberLabel
@onready var buttons_container = $VBoxContainer/ButtonsContainer
@onready var result_label = $ResultLabel
# Your instruction label is already set up in your scene, so not declared here

var numbers = [1, 2, 3, 4]
var shown_numbers = []
var current_index = 0
var last_number = null
var can_click = false

func _ready():
	result_label.text = ""
	result_label.add_theme_color_override("font_color", Color.WHITE)
	_show_next_number()

func _show_next_number():
	result_label.text = ""
	can_click = false
	# Clear buttons
	for child in buttons_container.get_children():
		child.queue_free()
	# Create buttons
	for num in numbers:
		var btn = Button.new()
		btn.text = str(num)
		btn.name = str(num)
		btn.custom_minimum_size = Vector2(120, 120)
		btn.connect("pressed", Callable(self, "_on_button_pressed").bind(btn))
		btn.add_theme_color_override("font_color", Color.BLACK)
		buttons_container.add_child(btn)
	# Start number sequence
	_start_showing_sequence()

func _start_showing_sequence():
	shown_numbers.clear()
	current_index = 0
	_show_number_once()

func _show_number_once():
	if current_index < 4:
		last_number = numbers[randi() % numbers.size()]
		number_label.text = str(last_number)
		number_label.add_theme_color_override("font_color", Color.BLACK)
		shown_numbers.append(last_number)
		current_index += 1
		can_click = false
		# Show number 0.8s, then hide 0.3s
		var t1 = Timer.new()
		t1.wait_time = 0.8
		t1.one_shot = true
		t1.connect("timeout", Callable(self, "_hide_number"))
		add_child(t1)
		t1.start()
	else:
		can_click = true
		number_label.text = ""  # number_label only shows numbers
		# Instructions should be handled by your instruction label elsewhere
		# So no code here for instructions

func _hide_number():
	number_label.text = ""
	var t2 = Timer.new()
	t2.wait_time = 0.3
	t2.one_shot = true
	t2.connect("timeout", Callable(self, "_show_number_once"))
	add_child(t2)
	t2.start()

func _on_button_pressed(pressed_button):
	if not can_click:
		return
	var pressed_num = int(pressed_button.text)
	if pressed_num == last_number:
		result_label.text = "✅ Teisingai!"
		emit_signal("task_completed", true)
	else:
		result_label.text = "❌ Neteisingai!"
		emit_signal("task_completed", false)
	can_click = false
	number_label.text = ""
	# Restart after 2 seconds
	var t_restart = Timer.new()
	t_restart.wait_time = 2.0
	t_restart.one_shot = true
	t_restart.connect("timeout", Callable(self, "_show_next_number"))
	add_child(t_restart)
	t_restart.start()

signal task_completed(correct: bool)

func is_correct() -> bool:
	return result_label.text == "✅ Teisingai!"  # or use a variable like `completed_correctly`
