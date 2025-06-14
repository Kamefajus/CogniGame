extends Control

# Reference to the result label (drag it in the editor)
@onready var result_label = $Label

func _ready():
	# Connect all TextureButton pressed signals
	for button in $HBoxContainer.get_children():
		if button is TextureButton:
			button.pressed.connect(_on_button_pressed.bind(button))

func _on_button_pressed(button: TextureButton):
	if button.name == "TextureButton3":  # Directly check for TextureButton3
		show_result("✅ Teisingai!", Color.WHITE)
		animate_button(button, 1.2, Color.GREEN)
	else:
		show_result("❌ Neteisingai!", Color.WHITE)
		animate_button(button, 0.9, Color.RED)

func show_result(text: String, color: Color):
	if result_label:
		result_label.text = text
		result_label.modulate = color
		
		# Animate the label
		var tween = create_tween()
		tween.tween_property(result_label, "scale", Vector2(1.2, 1.2), 0.1)
		tween.tween_property(result_label, "scale", Vector2(1.0, 1.0), 0.2)

func animate_button(button: TextureButton, scale: float, color: Color):
	var tween = create_tween().set_parallel(true)
	tween.tween_property(button, "scale", Vector2(scale, scale), 0.15)
	tween.tween_property(button, "modulate", color, 0.1)
	tween.chain().tween_property(button, "scale", Vector2(1.0, 1.0), 0.25)
	tween.parallel().tween_property(button, "modulate", Color.WHITE, 0.25)
