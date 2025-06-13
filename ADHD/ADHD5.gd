extends Node2D

var colors = [Color.RED, Color.GREEN, Color.BLUE, Color.YELLOW, Color.PURPLE]
var current_color_index = 0
var change_interval = 2.0
var timer := 0.0

@onready var color_box = $ColorBox
@onready var result_label = $ResultLabel  # Make sure you have a Label node named ResultLabel

func _ready():
	color_box.color = colors[current_color_index]
	result_label.text = ""
	result_label.visible = false

func _process(delta):
	timer += delta
	if timer >= change_interval:
		timer = 0.0
		_change_color()

func _change_color():
	current_color_index = (current_color_index + 1) % colors.size()
	color_box.color = colors[current_color_index]

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if color_box.get_global_rect().has_point(event.position):
			if color_box.color == Color.BLUE:
				_show_result(true)
			else:
				_show_result(false)

func _show_result(is_correct: bool):
	if is_correct:
		result_label.text = "✅ Teisingai! Spalva mėlyna!" 
		emit_signal("task_completed", true)
	else:
		"❌ Neteisingai. Tai ne mėlyna spalva."
		emit_signal("task_completed", false)
	result_label.visible = true
	

	# Hide result after a short delay
	await get_tree().create_timer(2.0).timeout
	result_label.visible = false


signal task_completed(correct: bool)

func is_correct() -> bool:
	return result_label.text == "✅ Teisingai! Spalva mėlyna!" 
