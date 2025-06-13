extends Control

@onready var hbox_container: HBoxContainer = $HBoxContainer
@onready var result_label: Label = $ResultLabel

# Store original modulate colors
var original_colors = {}
var brightest_button_name = "TextureButton3"  # Set this to your brightest button

func _ready():
	if not hbox_container:
		push_error("HBoxContainer not found!")
		return
	
	# Store original colors and connect buttons
	for button in hbox_container.get_children():
		if button is TextureButton:
			original_colors[button] = button.modulate  # Store original color
			button.pressed.connect(_on_button_pressed.bind(button))
			button.mouse_entered.connect(_on_button_hover.bind(button, true))
			button.mouse_exited.connect(_on_button_hover.bind(button, false))
	
	if result_label:
		result_label.visible = false
	else:
		push_error("ResultLabel not found!")

func _on_button_pressed(button: TextureButton):
	# Reset all buttons to their original colors
	for btn in original_colors:
		btn.modulate = original_colors[btn]
		btn.scale = Vector2(1, 1)
	
	# Highlight selected button while preserving base color
	var highlight_color = original_colors[button] * Color(0.8, 0.8, 1.2)  # Blend with light blue
	button.modulate = highlight_color
	
	var tween = create_tween()
	tween.tween_property(button, "scale", Vector2(1.1, 1.1), 0.1)
	
	if button.name == brightest_button_name:
		_show_result("✅ Teisingai!", Color(1, 1, 1))
	else:
		_show_result("❌ Neteisingai!", Color(1, 1, 1))

func _on_button_hover(button: TextureButton, is_hovered: bool):
	var tween = create_tween()
	if is_hovered and button.modulate == original_colors[button]:  # Only hover if not selected
		tween.tween_property(button, "scale", Vector2(1.05, 1.05), 0.1)
	elif not is_hovered and button.modulate == original_colors[button]:
		tween.tween_property(button, "scale", Vector2(1, 1), 0.1)

func _show_result(text: String, color: Color):
	if not result_label:
		return
		
	result_label.text = text
	result_label.add_theme_color_override("font_color", color)
	result_label.visible = true
	
	var tween = create_tween()
	tween.tween_property(result_label, "scale", Vector2(1.2, 1.2), 0.2)
	tween.tween_property(result_label, "scale", Vector2(1, 1), 0.3)
	tween.tween_callback(func(): result_label.visible = false).set_delay(1.5)
