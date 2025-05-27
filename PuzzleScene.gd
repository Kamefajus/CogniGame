extends Control

@onready var lbl_result = $VBoxContainer/lbl_result

@onready var btns = [
	$VBoxContainer/hbox_choices/btn_choice_1,
	$VBoxContainer/hbox_choices/btn_choice_2,
	$VBoxContainer/hbox_choices/btn_choice_3,
]

var shapes = [
	{"name": "square_stripes", "display_name": "Trikampis su zigzagais"},
	{"name": "triangle_dots", "display_name": "Penkiakampis us zigzagais"},
	{"name": "circle_grid", "display_name": "Kvadratas su taškais"},
]

var correct_btn_index = 2  # btn_choice_3 yra teisingas atsakymas (indeksas nuo 0)

func _ready():
	lbl_result.text = ""
	setup_buttons()

func setup_buttons():
	# Netinkamos figūros (be teisingos)
	var wrong_shapes = [
		shapes[0], # kvadratas
		shapes[2], # apskritimas
	]
	
	# Maišome neteisingas figūras (btn_choice_1 ir btn_choice_2)
	wrong_shapes.shuffle()
	
	# Užpildome mygtukus tekstu
	btns[0].text = wrong_shapes[0]["display_name"]
	btns[0].set_meta("shape_name", wrong_shapes[0]["name"])
	btns[0].connect("pressed", Callable(self, "_on_choice_pressed").bind(0))
	
	btns[1].text = wrong_shapes[1]["display_name"]
	btns[1].set_meta("shape_name", wrong_shapes[1]["name"])
	btns[1].connect("pressed", Callable(self, "_on_choice_pressed").bind(1))
	
	# Teisingas mygtukas (btn_choice_3)
	btns[2].text = shapes[1]["display_name"]  # trikampis (taškai)
	btns[2].set_meta("shape_name", shapes[1]["name"])
	btns[2].connect("pressed", Callable(self, "_on_choice_pressed").bind(2))

func _on_choice_pressed(btn_index: int):
	if btn_index == correct_btn_index:
		lbl_result.text = "✅ Teisingai!"
		lbl_result.add_theme_color_override("font_color", Color.GREEN)
	else:
		lbl_result.text = "❌ Bandyk dar kartą."
		lbl_result.add_theme_color_override("font_color", Color.RED)
