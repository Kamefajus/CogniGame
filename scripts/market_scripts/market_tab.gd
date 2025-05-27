extends TabBar

var tab_bar: TabBar
const COIN_ICON = preload("res://assets/pngimg.com - coin_PNG36871.png")


func _init(root: TabBar):
	tab_bar = root


func spawn_items(indx, name, price, id, is_owned, node) -> void:
	var rect = ColorRect.new()
	rect.size = Vector2(325, 200)
	rect.position = Vector2(75 + (indx % 3) * 335, 10 + floor(indx / 3) * 210)
	
	var label = Label.new()
	label.text = name
	label.position = Vector2(0, 10)
	label.size = Vector2(325, 20)
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", Color.BLACK)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	var button = Button.new()
	button.name = "Button_" + str(id)
	if is_owned:
		button.text = "Nupirkta"
		button.disabled = true
	else:
		button.text = "Pirkti"
		
	button.size = Vector2(100, 35)
	button.position = Vector2((rect.size.x - button.size.x) / 2, 150)
	button.pressed.connect(func(): tab_bar._on_button_pressed(button))
	button.pressed.connect(Callable(AudioManager, "play_click"))

	var panel = Panel.new()
	panel.size = Vector2(22, 22)
	panel.position = Vector2(15, 156)
	
	var stylebox = StyleBoxTexture.new()
	stylebox.texture = COIN_ICON
	panel.add_theme_stylebox_override("panel", stylebox)
	
	var price_label = Label.new()
	price_label.text = str(price)
	price_label.position = Vector2(40, 156)
	price_label.size = Vector2(75, 22)
	price_label.add_theme_font_size_override("font_size", 16)
	price_label.add_theme_color_override("font_color", Color.DARK_GOLDENROD)
	price_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	price_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	rect.add_child(price_label)
	rect.add_child(panel)
	rect.add_child(button)
	rect.add_child(label)
	
	node.add_child(rect)


func update(user_id: int, type: String) -> void:
	var items = Database.get_items_by_category(type)
	var owned_items = Database.get_owened_items_by_user(type, user_id)
	var adj_size = items.size() - 6
	if adj_size <= 0:
		tab_bar.get_node("VScrollBar").max_value = 0
	else:
		tab_bar.get_node("VScrollBar").max_value = (adj_size % 3) * 210
	var node = tab_bar.get_node("RichTextLabel/Node2D")
	var indx = 0
	for n in range(items.size()):
		if owned_items.size() <= indx:
			spawn_items(n, items[n]["name"], items[n]["price"], items[n]["id"], false, node)
		elif items[n]["id"] == owned_items[indx]['id']:
			spawn_items(n, items[n]["name"], items[n]["price"], items[n]["id"], true, node)
			indx = indx + 1
		else:
			spawn_items(n, items[n]["name"], items[n]["price"], items[n]["id"], false, node)
