extends Control

@onready var buttons = [
	$ColorButtonRed,
	$ColorButtonBlue,
	$ColorButtonGreen,
	$ColorButtonYellow
]
@onready var info_label = $InfoLabel

var base_colors = [
	Color(1, 0, 0),   # Raudona
	Color(0, 0, 1),   # Mėlyna
	Color(0, 1, 0),   # Žalia
	Color(1, 1, 0)    # Geltona
]

var sequence = []
var user_input = []
var sequence_length = 4
var showing_sequence = false
var restarting = false  # <-- Apsaugo nuo kelių restartų vienu metu

func _ready():
	for i in range(buttons.size()):
		buttons[i].pressed.connect(_on_button_pressed.bind(i))
	start_game()

func start_game():
	if restarting:
		return
	restarting = true
	info_label.text = "Stebėk seką..."
	user_input.clear()
	generate_sequence()
	showing_sequence = true
	await show_sequence()
	showing_sequence = false
	info_label.text = "Kartok seką!"
	restarting = false

func generate_sequence():
	sequence.clear()
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	for i in range(sequence_length):
		sequence.append(rng.randi_range(0, 3))
	print("Sugeneruota seka: ", sequence)

func _on_button_pressed(index):
	if showing_sequence or restarting:
		return  # Negalima spausti, kai rodoma seka ar vyksta restartas

	user_input.append(index)
	await flash_button(index)

	if user_input[user_input.size() - 1] != sequence[user_input.size() - 1]:
		info_label.text = "Pralaimėjai! Bandyk dar kartą."
		restarting = true
		await get_tree().create_timer(2.0).timeout
		start_game()
		return

	if user_input.size() == sequence_length:
		info_label.text = "Laimėjai!"
		restarting = true
		await get_tree().create_timer(2.0).timeout
		start_game()

func flash_button(index):
	var btn = buttons[index]
	var stylebox = btn.get_theme_stylebox("normal") as StyleBoxFlat
	var original_color = base_colors[index]
	stylebox.bg_color = Color(1, 1, 1)  # Užsidegimo spalva (balta)
	btn.queue_redraw()
	await get_tree().create_timer(0.5).timeout
	stylebox.bg_color = original_color
	btn.queue_redraw()

func show_sequence():
	for index in sequence:
		await flash_button(index)
		await get_tree().create_timer(0.3).timeout



func _on_button1_pressed() -> void:
	get_tree().change_scene_to_file("res://ADHD/ADHD8.tscn")


func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://ADHD/ADHD10.tscn")
