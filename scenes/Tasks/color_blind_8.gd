extends Control

@onready var result_label: Label = $ResultLabel  # Make sure the Label node exists in your scene and is named 'ResultLabel'

func _ready() -> void:
	result_label.text = ""
	result_label.visible = false

func _on_texture_button_pressed() -> void:
	show_result_bad()

func _on_texture_button_2_pressed() -> void:
	show_result_bad()

func _on_texture_button_3_pressed() -> void:
	show_result_bad()

func _on_texture_button_4_pressed() -> void:
	show_result_bad()

func _on_texture_button_5_pressed() -> void:
	var id = Database.curr_uid
	var curr_money = Database.get_user_money_amount(id)
	Database.update_user_money_amount(id, curr_money + 5)
	show_result_good()

func show_result_good():
	result_label.text = "✅ Teisingai!"
	result_label.add_theme_color_override("font_color", Color.WHITE)
	result_label.visible = true
	animate_label()

func show_result_bad():
	result_label.text = "❌ Neteisingai! Bandyk dar kartą"
	result_label.add_theme_color_override("font_color", Color.WHITE)
	result_label.visible = true
	animate_label()

func animate_label():
	# Optional bounce animation
	result_label.scale = Vector2(1, 1)
	var tween = create_tween()
	tween.tween_property(result_label, "scale", Vector2(1.2, 1.2), 0.2)
	tween.tween_property(result_label, "scale", Vector2(1.0, 1.0), 0.2)
