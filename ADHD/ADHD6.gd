extends Control

@onready var cover = $Cover
@onready var result_label = $Label

var original_positions = {}
var figures: Array[TextureButton] = []
var dynamic_obj: TextureButton = null
var clicked = false

var highlight_positions = [
	Vector2(269, 165),
	Vector2(966, 286),
	Vector2(334, 552)
]

func _ready():
	result_label.text = ""
	clicked = false
	cover.visible = false  # Start invisible

	_get_figures()
	_store_original_positions()
	_assign_button_signals()

	print("🟢 Scena paleista")
	print("Figures found: %d" % figures.size())
	for f in figures:
		print(" - ", f.name, "at", f.position)

	_pick_dynamic_object()
	_start_movement_sequence()

func _get_figures():
	figures.clear()
	for child in get_children():
		if child is TextureButton and child != cover and child != result_label:
			figures.append(child)

func _store_original_positions():
	original_positions.clear()
	for fig in figures:
		original_positions[fig] = fig.position

func _assign_button_signals():
	for button in figures:
		button.connect("pressed", Callable(self, "_on_button_pressed").bind(button))

func _pick_dynamic_object():
	if figures.size() == 0:
		return
	dynamic_obj = figures[randi() % figures.size()]
	print("Dinaminė figūra:", dynamic_obj.name)

func _start_movement_sequence() -> void:
	await get_tree().create_timer(5.0).timeout
	cover.visible = true
	await get_tree().create_timer(0.3).timeout

	if dynamic_obj == null:
		cover.visible = false
		return

	var target_pos = highlight_positions[randi() % highlight_positions.size()]
	print("Moving dynamic figure", dynamic_obj.name, "to", target_pos)

	var tween = create_tween()
	tween.tween_property(dynamic_obj, "position", target_pos, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	await tween.finished
	cover.visible = false

func _on_button_pressed(button: TextureButton):
	if clicked:
		return

	clicked = true

	if button == dynamic_obj:
		result_label.text = "✅ Teisingai!"
		emit_signal("task_completed", true)
	else:
		result_label.text = "❌ Neteisingai. Bandyk dar kartą!"
		emit_signal("task_completed", false)
		
signal task_completed(correct: bool)

func is_correct() -> bool:
	return result_label.text == "✅ Teisingai!"  # or use a variable like `completed_correctly`
