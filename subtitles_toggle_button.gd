extends Control


@onready var label = $HBoxContainer/Label2 as Label
@onready var check_button = $HBoxContainer/CheckButton as CheckButton

func _ready():
	check_button.toggled.connect(on_subtitles_toggled)

func set_label_text(button_pressed : bool) -> void:
	if button_pressed != true:
		label.text = "Išjungta"
	else:
		label.text = "Įjungta"


func on_subtitles_toggled(button_pressed : bool) -> void:
	set_label_text(button_pressed)
