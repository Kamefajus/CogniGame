extends Node2D

@onready var number_label = $NumberLabel
@onready var buttons_container = $VBoxContainer/ButtonsContainer
@onready var result_label = $VBoxContainer/ResultLabel

var numbers = [1, 2, 3, 4]
var shown_numbers = []
var current_index = 0
var last_number = null
var can_click = false

func _ready():
	result_label.text = ""
	_show_next_number()

func _show_next_number():
	result_label.text = ""
	can_click = false
	# Išvalom mygtukus
	for child in buttons_container.get_children():
		child.queue_free()
	# Sukuriam mygtukus
	for num in numbers:
		var btn = Button.new()
		btn.text = str(num)
		btn.name = str(num)
		btn.connect("pressed", Callable(self, "_on_button_pressed").bind(btn))
		buttons_container.add_child(btn)
	# Pradėsim skaičių rodymą
	_start_showing_sequence()

func _start_showing_sequence():
	shown_numbers.clear()
	current_index = 0
	_show_number_once()

func _show_number_once():
	if current_index < 4:
		last_number = numbers[randi() % numbers.size()]
		number_label.text = str(last_number)
		shown_numbers.append(last_number)
		current_index += 1
		can_click = false
		# Parodome skaičių 0.8 sek, tada slepiam 0.3 sek
		var t1 = Timer.new()
		t1.wait_time = 0.8
		t1.one_shot = true
		t1.connect("timeout", Callable(self, "_hide_number"))
		add_child(t1)
		t1.start()
	else:
		# Po keturių rodymų leidžiam spausti mygtukus
		can_click = true
		number_label.text = "Paspausk paskutinį skaičių!"

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
		result_label.text = "Laimejai!"
	else:
		result_label.text = "Pralaimejai!"
	can_click = false
	number_label.text = ""
	# Po 2 sekundžių pradėti žaidimą iš naujo
	var t_restart = Timer.new()
	t_restart.wait_time = 2.0
	t_restart.one_shot = true
	t_restart.connect("timeout", Callable(self, "_show_next_number"))
	add_child(t_restart)
	t_restart.start()
