extends Control

var selected_buttons := []
var tween: Tween

func _ready():
	tween = create_tween()
	tween.set_parallel(true)
	
	print("Shapes in group:", get_tree().get_nodes_in_group("shapes"))
	for child in get_children():
		if child is TextureButton:
			child.connect("pressed", Callable(self, "_on_button_pressed").bind(child))
			print("Connected to button: ", child.name)
			child.pivot_offset = child.size / 2  # Center pivot for scaling

func _on_button_pressed(button):
	# Toggle selection
	if button in selected_buttons:
		selected_buttons.erase(button)
		_deselect_button(button)
	else:
		selected_buttons.append(button)
		_select_button(button)
	
	_check_selection()

func _select_button(button: TextureButton):
	# Animate selection
	tween = create_tween().set_parallel(true)
	tween.tween_property(button, "modulate", Color(0.3, 1, 0.3), 0.2)
	tween.tween_property(button, "scale", Vector2(1.2, 1.2), 0.15)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.chain().tween_property(button, "scale", Vector2(1.0, 1.0), 0.15)\
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_ELASTIC)
	
	# Add pulsing effect
	var pulse_tween = create_tween().set_loops()
	pulse_tween.tween_property(button, "modulate", Color(0.6, 1, 0.6), 0.8)
	pulse_tween.tween_property(button, "modulate", Color(0.3, 1, 0.3), 0.8)
	button.set_meta("pulse_tween", pulse_tween)

func _deselect_button(button: TextureButton):
	# Stop any existing animations
	if button.has_meta("pulse_tween"):
		var pulse_tween: Tween = button.get_meta("pulse_tween")
		pulse_tween.kill()
	
	# Animate deselection
	tween = create_tween().set_parallel(true)
	tween.tween_property(button, "modulate", Color(1, 1, 1), 0.2)
	tween.tween_property(button, "scale", Vector2(0.9, 0.9), 0.1)\
		.set_ease(Tween.EASE_OUT)
	tween.chain().tween_property(button, "scale", Vector2(1.0, 1.0), 0.15)\
		.set_ease(Tween.EASE_IN_OUT)

func _check_selection():
	# Get all triangle buttons by name (more reliable than groups)
	var triangle_names = ["triangle1", "triangle2", "triangle3"]
	var triangle_buttons = []
	for name in triangle_names:
		if has_node(name):
			triangle_buttons.append(get_node(name))
	
	if selected_buttons.size() == 3:
		# Check if all selected buttons are triangle buttons
		var all_triangles = true
		for button in selected_buttons:
			if not triangle_buttons.has(button):
				all_triangles = false
				break
		
		if all_triangles:
			show_result("✅ Teisingai: visi trikampiai pasirinkti!", Color(1, 1, 1))
			var id = Database.curr_uid
			var curr_money = Database.get_user_money_amount(id)
			Database.update_user_money_amount(id, curr_money + 5)
			for button in selected_buttons:
				_celebrate_button(button)
		else:
			show_result("❌ Klaida: pasirinkti neteisingi objektai.", Color(1, 1, 1))
	else:
		show_result("", Color(1, 1, 1))  # Clear if less than 3

func _celebrate_button(button: TextureButton):
	var tween = create_tween().set_parallel(true)
	tween.tween_property(button, "scale", Vector2(1.3, 1.3), 0.2)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(button, "rotation", deg_to_rad(15), 0.2)
	tween.chain().tween_property(button, "scale", Vector2(1.0, 1.0), 0.3)\
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.parallel().tween_property(button, "rotation", deg_to_rad(0), 0.3)

func show_result(text: String, color: Color):
	if has_node("result_label"):
		var label = $result_label
		label.text = text
		label.add_theme_color_override("font_color", color)
		
		# Animate the result text
		var tween = create_tween()
		tween.tween_property(label, "scale", Vector2(1.2, 1.2), 0.15)\
			.set_ease(Tween.EASE_OUT)
		tween.chain().tween_property(label, "scale", Vector2(1.0, 1.0), 0.25)\
			.set_ease(Tween.EASE_IN_OUT)
	else:
		print("❗ result_label not found in scene")
