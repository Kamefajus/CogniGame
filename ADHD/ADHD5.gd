extends Node2D

var colors = [Color.RED, Color.GREEN, Color.BLUE, Color.YELLOW, Color.PURPLE]
var current_color_index = 0
var change_interval = 2.0
var timer := 0.0

@onready var color_box = $ColorBox
@onready var result_popup = $ResultPopup

func _ready():
	color_box.color = colors[current_color_index]
	result_popup.confirmed.connect(_on_result_popup_confirmed)
	
	# Jei nenaudoji pauzės, šios eilutės galima pašalinti:
	# result_popup.pause_mode = 2

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
	result_popup.dialog_text = "✅ Teisingai! Spalva mėlyna!" if is_correct else "❌ Neteisingai. Tai ne mėlyna spalva."
	result_popup.popup_centered()

func _on_result_popup_confirmed():
	# Jei nenaudojam pauzės, šios eilutės taip pat nereikia
	pass
