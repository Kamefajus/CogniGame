extends Control

var rate_sys = load("res://scripts/rating_system.gd").new()

func _ready() -> void:
	rate_sys.spawn_items($Panel/Panel2, "res://scenes/main_menu.tscn")
	#var star = Polygon2D.new()
	#star.name = "Star_" + str(indx)
	#star.position = Vector2(380+50*(indx-3), 245)
	#star.polygon = generate_star_points(5, 20, 11)
	#star.color = Color.WHITE
	#
	#var button = TextureButton.new()
	#button.name = "Button_" + str(indx)
	#button.size = Vector2(40, 40)
	#button.position = Vector2(-20, -20)
	#button.pressed.connect(func(): _on_texture_button_pressed(button))
	#button.mouse_entered.connect(func(): _on_texture_button_mouse_entered(button))
	#button.mouse_exited.connect(func(): _on_texture_button_mouse_exited(button))
	#star.add_child(button)
	#
	#return star
