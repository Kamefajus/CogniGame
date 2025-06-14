extends Control

@onready var hbox = $HBoxContainer
@onready var result_label = $ResultLabel
@onready var submit_button = $SubmitButton

var selected = []
var colors = [
	Color("#333333"),  # Darkest
	Color("#999999"),
	Color("#cccccc"),
	Color("#f2f2f2")   # Lightest
]
var brightness_order = []
var color_rects = []

func _ready():
	# Store brightness order (darkest to lightest)
	brightness_order = colors.duplicate()
	brightness_order.sort_custom(Callable(self, "_compare_brightness"))
	
	# Clear any existing color rects
	for child in hbox.get_children():
		child.queue_free()
	color_rects.clear()
	selected.clear()
	
	# Shuffle colors
	var shuffled_colors = colors.duplicate()
	shuffled_colors.shuffle()
	
	# Create ColorRects in HBoxContainer
	for i in range(shuffled_colors.size()):
		var color_rect = ColorRect.new()
		color_rect.color = shuffled_colors[i]
		color_rect.custom_minimum_size = Vector2(100, 100)
		color_rect.mouse_filter = Control.MOUSE_FILTER_PASS
		color_rect.connect("gui_input", Callable(self, "_on_color_pressed").bind(i))
		hbox.add_child(color_rect)
		color_rects.append(color_rect)
	
	submit_button.connect("pressed", Callable(self, "_on_submit_pressed"))

func _compare_brightness(a: Color, b: Color) -> bool:
	return a.v < b.v  # Sort from darkest to lightest

func _on_color_pressed(event: InputEvent, index: int):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if selected.has(index):
			return  # Already selected
		
		selected.append(index)
		color_rects[index].modulate.a = 0.6  # Visual feedback
		color_rects[index].size_flags_vertical = Control.SIZE_SHRINK_CENTER

func _on_submit_pressed():
	if selected.size() != colors.size():
		result_label.text = "Pasirink visas spalvas!"
		return
	
	# Check if selected order matches brightness order
	var is_correct = true
	for i in range(selected.size()):
		if color_rects[selected[i]].color != brightness_order[i]:
			is_correct = false
			break
	
	result_label.text = "✅ Teisingai!" if is_correct else "❌ Neteisinga tvarka. Bandyk dar kartą."
	
	# Reset for next attempt
	for i in selected:
		color_rects[i].modulate.a = 1.0
	selected.clear()
	
	# Optional: Auto-reshuffle colors
	_ready()
