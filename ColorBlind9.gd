extends Control

@onready var nodes = $ColorNodeContainer.get_children()
@onready var result_label = $ResultLabel

var selected = []
var brightness_order = [] # Tikroji seka nuo šviesiausios iki tamsiausios

func _ready():
	# Nustatome atsitiktinę spalvų eilę
	var colors = [
		Color("#f2f2f2"), # labai šviesi
		Color("#cccccc"),
		Color("#999999"),
		Color("#333333"), # tamsi
	]
	colors.shuffle()
	brightness_order = colors.duplicate()
	brightness_order.sort_custom(Callable(self, "compare_brightness"))


	for i in range(nodes.size()):
		nodes[i].modulate = colors[i]
		nodes[i].connect("pressed", Callable(self, "_on_node_pressed").bind(i))

func compare_brightness(a, b):
	return a.get_v() < b.get_v() # lygina HSV šviesumą

func _on_node_pressed(index):
	if selected.has(index):
		return
	selected.append(index)
	nodes[index].modulate.a = 0.6 # pažymėjimui

func _on_SubmitButton_pressed():
	if selected.size() != nodes.size():
		result_label.text = "Pasirink visus tonus!"
		return

	var selected_colors = []
	for i in selected:
		selected_colors.append(nodes[i].modulate)
	
	selected_colors.sort_custom(Callable(self, "compare_brightness"))


	var is_correct = true
	for i in range(selected_colors.size()):
		if selected_colors[i] != brightness_order[i]:
			is_correct = false
			break
	
	if is_correct:
		result_label.text = "Teisingai! 🎉"
	else:
		result_label.text = "Neteisinga tvarka, bandyk dar kartą."
