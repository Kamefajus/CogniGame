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


func _on_none_button_pressed() -> void:
	ColorProfile.mode = "normal"
	ColorProfile.apply()


func _on_prota_button_pressed() -> void:
	ColorProfile.mode = "protanopia"
	ColorProfile.apply()


func _on_deuter_button_pressed() -> void:
	ColorProfile.mode = "deuteranopia"
	ColorProfile.apply()


func _on_trita_button_pressed() -> void:
	ColorProfile.mode = "tritanopia"
	ColorProfile.apply()


func _on_achroma_button_pressed() -> void:
	ColorProfile.mode = "achromatopsia"
	ColorProfile.apply()
