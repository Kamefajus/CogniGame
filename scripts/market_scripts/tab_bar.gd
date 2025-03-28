extends TabBar

var node
var u_id = 1
var answer_array = [["Name", 1, false], ["Name2", 2, false], ["Name3", 3, false],
 ["Name4", 4, false], ["Name5", 5, false], ["Name", 6, false], ["Name", 7, false]]
var is_clear = true

signal update_money(id: int)

func _ready() -> void:
	Database._ready()
	update(u_id)


func _process(delta: float) -> void:
	$RichTextLabel/Node2D.position.y = -$VScrollBar.value


func spawn_items(indx, name, price, id, is_owned) -> void:
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
	button.position = Vector2((rect.size.x - button.size.x) / 2, 150)  # Center the button
	button.pressed.connect(func(): _on_button_pressed(button))

	var panel = Panel.new()
	panel.size = Vector2(22, 22)
	panel.position = Vector2(15, 156)
	
	var stylebox = StyleBoxTexture.new()
	stylebox.texture = load("res://assets/pngimg.com - coin_PNG36871.png")
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


func _on_button_pressed(button: Button) -> void:
	print(button.name + " was clicked!")
	if is_clear:
		is_clear = false
		emit_signal("update_money", int(button.name.split("_")[1]))


func update(user_id: int) -> void:
	var items = Database.get_items_by_category("avatar")
	var owned_items = Database.get_owened_items_by_user("avatar", user_id)
	var adj_size = items.size() - 6
	if adj_size <= 0:
		$VScrollBar.max_value = 0
	else:
		$VScrollBar.max_value = (adj_size % 3) * 210
	node = $RichTextLabel/Node2D
	var indx = 0
	for n in range(items.size()):
		if owned_items.size() <= indx:
			spawn_items(n, items[n]["name"], items[n]["price"], items[n]["id"], false)
		elif items[n]["id"] == owned_items[indx]['id']:
			spawn_items(n, items[n]["name"], items[n]["price"], items[n]["id"], true)
			indx = indx + 1
		else:
			spawn_items(n, items[n]["name"], items[n]["price"], items[n]["id"], false)


func _on_market_update(change: bool) -> void:
	if change:
		update(u_id)
		is_clear = true
	else:
		is_clear = true
