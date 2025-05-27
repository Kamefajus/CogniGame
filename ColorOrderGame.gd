extends Control

@onready var grid = $Vbox/ColorGrid
@onready var result_label = $Vbox/ResultLabel
@onready var submit_button = $Vbox/SubmitButton

var selected = []
var colors = [
	Color("#f2f2f2"),
	Color("#cccccc"),
	Color("#999999"),
	Color("#333333"),
]
var brightness_order = []

func _ready():
	brightness_order = colors.duplicate()
	brightness_order.sort_custom(Callable(self, "compare_brightness"))

	# Priskiriame spalvas visiems ColorRect'ams NEIŠMAIŠYTA tvarka (vienoje vietoje)
	for i in range(grid.get_child_count()):
		var rect = grid.get_child(i) as ColorRect
		rect.color = colors[i]
		rect.mouse_filter = Control.MOUSE_FILTER_PASS
		rect.modulate.a = 1.0
		rect.connect("gui_input", Callable(self, "_on_color_pressed").bind(i))

	submit_button.connect("pressed", Callable(self, "_on_submit_pressed"))

func compare_brightness(a, b):
	if a.v < b.v:
		return -1
	elif a.v > b.v:
		return 1
	else:
		return 0

func _on_color_pressed(event: InputEvent, index: int):
	if event is InputEventMouseButton and event.pressed:
		if selected.has(index):
			# Jei jau pasirinkta, neleidžiam pasirinkti pakartotinai
			return
		selected.append(index)
		grid.get_child(index).modulate.a = 0.6  # pažymim pasirinkimą vizualiai

func _on_submit_pressed():
	if selected.size() != grid.get_child_count():
		result_label.text = "Pasirink visas spalvas!"
		return

	var selected_colors = []
	for i in selected:
		selected_colors.append(grid.get_child(i).color)

	# Patikrinam ar pasirinkta tvarka atitinka šviesumo tvarką
	var is_correct = true
	for i in range(selected_colors.size()):
		if selected_colors[i] != brightness_order[i]:
			is_correct = false
			break

	if is_correct:
		result_label.text = "Teisingai! 🎉"
	else:
		result_label.text = "Neteisinga tvarka. Bandyk dar kartą."

	# Atstatom spalvų moduliaciją ir išvalom pasirinkimus
	for i in selected:
		grid.get_child(i).modulate.a = 1.0
	selected.clear()
