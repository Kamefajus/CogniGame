extends Control

var correct_order = []
var current_index = 0

func _ready():
	correct_order = [
		$TextureButton1,
		$TextureButton2,
		$TextureButton3,
		$TextureButton4
	]

	# Nustatome skirtingus dydžius
	$TextureButton1.scale = Vector2(0.5, 0.5)
	$TextureButton2.scale = Vector2(0.8, 0.8)
	$TextureButton3.scale = Vector2(1.0, 1.0)
	$TextureButton4.scale = Vector2(1.3, 1.3)

	randomize_buttons_position()

	# Prijungiame paspaudimo signalus
	for button in correct_order:
		button.pressed.connect(_on_button_pressed.bind(button))

	print("🟢 Žaidimas pradėtas! Paspausk mygtukus nuo mažiausio iki didžiausio.")

func randomize_buttons_position():
	var used_positions = []
	var screen_size = get_viewport_rect().size

	for button in correct_order:
		var new_pos = Vector2()
		var attempts = 0
		while true:
			new_pos = Vector2(
				randi() % int(screen_size.x - 100),
				randi() % int(screen_size.y - 100)
			)
			var too_close = false
			for pos in used_positions:
				if pos.distance_to(new_pos) < 100:
					too_close = true
					break
			if not too_close or attempts > 10:
				break
			attempts += 1
		button.position = new_pos
		used_positions.append(new_pos)

func _on_button_pressed(button):
	var expected_button = correct_order[current_index]
	if button == expected_button:
		print("✅ Teisingas mygtukas paspaustas! Indeksas:", current_index)
		button.disabled = true
		current_index += 1
		if current_index >= correct_order.size():
			show_success()
	else:
		print("❌ Neteisingas mygtukas! Tikėtasi:", correct_order[current_index].name, "– Bet paspausta:", button.name)

func show_success():
	print("🎉 Visi mygtukai paspausti teisingai! Užduotis atlikta.")
func on_tab_entered():
	set_process(true)
	set_physics_process(true)
	visible = true
	# Resume timers, animations, etc.

func on_tab_exited():
	set_process(false)
	set_physics_process(false)
	visible = false


func _on_button1_pressed() -> void:
	get_tree().change_scene_to_file("res://ADHD/ADHD3.tscn")


func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://ADHD/ADHD5.tscn")
