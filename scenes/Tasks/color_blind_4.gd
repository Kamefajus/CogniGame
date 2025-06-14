extends Control

var selected_buttons = []
var correct_buttons = ["TextureButton1", "TextureButton2"]  # Set your correct buttons here
var popup_label: Label
var selection_limit = 2  # Maximum number of selectable items

func _ready():
	# Assume popup_label was placed in the scene manually
	popup_label = $ResultLabel  # Get the Label from the scene
	popup_label.text = "✅ Teisingai!"
	popup_label.visible = false
	popup_label.add_theme_color_override("font_color", Color(1, 1, 1))  # White
	popup_label.add_theme_font_size_override("font_size", 48)
	popup_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	popup_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP

	# Connect TextureButtons
	for button in get_children():
		if button is TextureButton:
			button.connect("pressed", _on_texture_button_pressed.bind(button))
			button.mouse_entered.connect(_on_button_hover.bind(button, true))
			button.mouse_exited.connect(_on_button_hover.bind(button, false))




func _on_texture_button_pressed(button: TextureButton):
	# If already selected, deselect it
	if button in selected_buttons:
		selected_buttons.erase(button)
		_reset_button_appearance(button)
		_check_selection()
		return
	
	# If selection limit reached, show message and return
	if selected_buttons.size() >= selection_limit:
		_show_limit_reached()
		return
	
	# Select the button
	selected_buttons.append(button)
	_update_button_appearance(button)
	_check_selection()

func _on_button_hover(button: TextureButton, is_hovered: bool):
	if button in selected_buttons:
		return  # Don't change appearance of selected buttons
	
	if is_hovered:
		var tween = create_tween()
		tween.tween_property(button, "scale", Vector2(1.05, 1.05), 0.1)
	else:
		var tween = create_tween()
		tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.1)

func _update_button_appearance(button: TextureButton):
	# Visual feedback for selected button
	var tween = create_tween()
	tween.tween_property(button, "modulate", Color(0.5, 1, 0.5), 0.1)  # Green tint
	tween.parallel().tween_property(button, "scale", Vector2(1.1, 1.1), 0.1)

func _reset_button_appearance(button: TextureButton):
	# Reset to normal appearance
	var tween = create_tween()
	tween.tween_property(button, "modulate", Color(1, 1, 1), 0.1)  # White
	tween.parallel().tween_property(button, "scale", Vector2(1.0, 1.0), 0.1)

func _check_selection():
	popup_label.visible = false
	
	# Only check if we have exactly 2 selections
	if selected_buttons.size() == selection_limit:
		var all_correct = true
		for button in selected_buttons:
			if not correct_buttons.has(button.name):
				all_correct = false
				break
		
		if all_correct:
			_show_success()
		else:
			_show_failure()

func _show_success():
	popup_label.text = "✅ Teisingai!"
	popup_label.visible = true
	
	# Celebration animation
	var tween = create_tween()
	tween.tween_property(popup_label, "scale", Vector2(1.5, 1.5), 0.2)
	tween.tween_property(popup_label, "scale", Vector2(1, 1), 0.3)
	
	# Pulse all correct buttons
	for button in selected_buttons:
		var pulse_tween = create_tween().set_loops()
		pulse_tween.tween_property(button, "scale", Vector2(1.15, 1.15), 0.5)
		pulse_tween.tween_property(button, "scale", Vector2(1.1, 1.1), 0.5)


func _show_failure():
	popup_label.text = "❌ Neteisingai!"
	popup_label.add_theme_color_override("font_color", Color(0, 0, 0))
	popup_label.visible = true
	
	
	# Red flash for incorrect buttons
	for button in selected_buttons:
		if not correct_buttons.has(button.name):
			var flash_tween = create_tween()
			flash_tween.tween_property(button, "modulate", Color(1, 0.5, 0.5), 0.1)
			flash_tween.tween_property(button, "modulate", Color(0.5, 1, 0.5), 0.2)

func _show_limit_reached():
	# Temporary message when trying to select more than allowed
	var limit_label = Label.new()
	limit_label.text = "Pasirinkta maksimalus kiekis (%d)!" % selection_limit
	limit_label.add_theme_color_override("font_color", Color(1, 1, 0))
	limit_label.position = Vector2(300, 250)
	limit_label.add_theme_font_size_override("font_size", 24)
	add_child(limit_label)
	
	var tween = create_tween()
	tween.tween_property(limit_label, "modulate:a", 0.0, 1.0)
	tween.tween_callback(limit_label.queue_free)
