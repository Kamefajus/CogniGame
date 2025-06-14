extends Control

@onready var result_label: Label = $ResultLabel  # Make sure this Label node exists in your scene

func _ready() -> void:
	result_label.visible = false
	result_label.text = ""

func _on_button_pressed() -> void:
	var id = Database.curr_uid
	var curr_money = Database.get_user_money_amount(id)
	Database.update_user_money_amount(id, curr_money + 5)
	show_result_good()

func _on_button_2_pressed() -> void:
	show_result_bad()

func _on_button_3_pressed() -> void:
	show_result_bad()

func show_result_good():
	result_label.text = "✅ Teisingai!"
	result_label.add_theme_color_override("font_color", Color.WHITE)
	result_label.visible = true
	animate_label()

func show_result_bad():
	result_label.text = "❌ Neteisinga! Bandyk dar kartą"
	result_label.add_theme_color_override("font_color", Color.WHITE)
	result_label.visible = true
	animate_label()

func animate_label():
	# Optional animation for visual feedback
	result_label.scale = Vector2(1, 1)
	var tween = create_tween()
	tween.tween_property(result_label, "scale", Vector2(1.2, 1.2), 0.2)
	tween.tween_property(result_label, "scale", Vector2(1.0, 1.0), 0.2)
