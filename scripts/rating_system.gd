extends Node


func spawn_items(panel: Node, scene: String) -> void:
	var label = Label.new()
	
	label.text = "Kaip vertinate užduotį?"
	label.position = Vector2(panel.size.x/2 - 80, panel.size.y/2 - 30) 
	panel.add_child(label)
	
	for i in range(1, 6):
		var star = generate_star(i, panel)
		panel.add_child(star)
	
	var button = Button.new()
	button.text = "Baigti"
	button.position = Vector2(panel.size.x - 170, panel.size.y - 70)
	button.size = Vector2(150, 50)
	button.pressed.connect(func(): _on_button_back_pressed(scene, panel))
	panel.add_child(button)


func update(number: int, root: Node) -> void:
	var is_already_selected = false
	for i in range(number):
		var star = root.get_node("Star_"+str(i+1))
		if(i+1 == number and star.color == Color.ORANGE and number != 5):
			is_already_selected = true
			break
		star.color = Color.ORANGE
	
	var indx = number + 1
	
	while is_already_selected and indx <= 5:
		var star = root.get_node("Star_"+str(indx))
		if(star.color == Color.ORANGE):
			star.color = Color.WHITE
			indx = indx + 1
		else:
			is_already_selected = false


func indicate(number: int, root: Node) -> void:
	var indx = number
	
	while indx > 0:
		var star = root.get_node("Star_"+str(indx))
		if(star.color == Color.WHITE):
			star.color = Color.YELLOW
			indx = indx - 1
		else:
			indx = 0


func deindicate(number: int, root: Node) -> void:
	var indx = number
	
	while indx > 0:
		var star = root.get_node("Star_"+str(indx))
		if(star.color == Color.YELLOW):
			star.color = Color.WHITE
			indx = indx - 1
		else:
			indx = 0


func _on_texture_button_pressed(button: TextureButton, root: Node) -> void:
	var number = int(button.name.split("_")[1])
	update(number, root)


func _on_texture_button_mouse_entered(button: TextureButton, root: Node) -> void:
	var number = int(button.name.split("_")[1])
	indicate(number, root)


func _on_texture_button_mouse_exited(button: TextureButton, root: Node) -> void:
	var number = int(button.name.split("_")[1])
	deindicate(number, root)


func generate_star_points(points: int, outer_radius: float, inner_radius: float) -> PackedVector2Array:
	var polygon = PackedVector2Array()
	var angle_step = PI / points
	
	for i in range(points * 2):
		var radius = outer_radius if i % 2 == 0 else inner_radius
		var angle = i * angle_step - PI / 2
		var x = cos(angle) * radius
		var y = sin(angle) * radius
		polygon.append(Vector2(x, y))
	
	return polygon


func generate_star(indx: int, root: Node) -> Polygon2D:
	var star = Polygon2D.new()
	star.name = "Star_" + str(indx)
	star.position = Vector2(root.size.x/2 + 50*(indx-3), root.size.y*0.6 - 20)
	star.polygon = generate_star_points(5, 20, 11)
	star.color = Color.WHITE
	
	var button = TextureButton.new()
	button.name = "Button_" + str(indx)
	button.size = Vector2(40, 40)
	button.position = Vector2(-20, -20)
	button.pressed.connect(func(): _on_texture_button_pressed(button, root))
	button.mouse_entered.connect(func(): _on_texture_button_mouse_entered(button, root))
	button.mouse_exited.connect(func(): _on_texture_button_mouse_exited(button, root))
	star.add_child(button)
	
	return star


func _on_button_back_pressed(scene: String, root: Node) -> void :
	root.get_tree().change_scene_to_file(scene)
