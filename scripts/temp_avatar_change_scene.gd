extends Control

@onready var avatar_panel = $Panel2
var is_pressed = false
var node

func _ready() -> void:
	Database._ready()
	$Panel2/Panel.hide()
	draw_options(1)
	update()
	pass


func change_equipped(old_id: int, new_id: int) -> void:
	var u_id = 1
	if old_id >= 0:
		Database.change_equipped_item(old_id, u_id)
	if new_id >= 0:
		Database.change_equipped_item(new_id, u_id)


func update() -> void:
	var avatar_eqiuped = Database.get_equipped_item('avatar', 1)
	var stylebox = StyleBoxTexture.new()
	if avatar_eqiuped.size() < 1:
		stylebox.texture = load("res://assets/avatars/7.png")
	else:
		stylebox.texture = load(avatar_eqiuped[0]['asset'])
	avatar_panel.add_theme_stylebox_override("panel", stylebox)


func _on_avatar_panel_pressed() -> void:
	is_pressed = not is_pressed
	if is_pressed:
		$Panel2/Panel.show()
	else:
		$Panel2/Panel.hide()


func draw_options(user_id: int) -> void:
	var owned_items = Database.get_owened_items_by_user("avatar", user_id)
	var adj_size = owned_items.size() - 15
	if adj_size <= 0:
		$Panel2/Panel/VScrollBar.max_value = 0
	else:
		$Panel2/Panel/VScrollBar.max_value = (adj_size % 4) * 60
	node = $Panel2/Panel/RichTextLabel/Node2D
	spawn_items(0, "res://assets/avatars/7.png", -1)
	var indx = 1
	for n in range(owned_items.size()):
			spawn_items(indx, owned_items[n]["asset"], owned_items[n]["id"])
			indx = indx + 1


func spawn_items(indx, asset, id) -> void:
	var panel = Panel.new()
	panel.size = Vector2(50, 50)
	panel.position = Vector2(10 + (indx % 4) * 60, 10 + floor(indx / 4) * 60)
	print(Vector2(10 + (indx % 4) * 60, 10 + floor(indx / 4) * 60))
	
	var stylebox = StyleBoxTexture.new()
	stylebox.texture = load(asset)
	panel.add_theme_stylebox_override("panel", stylebox)
	
	var button = TextureButton.new()
	button.name = "Button_" + str(id)
		
	button.size = Vector2(50, 50)
	button.position = Vector2(10 + (indx % 4) * 60, 10 + floor(indx / 4) * 60)
	button.pressed.connect(func(): _on_button_pressed(button))
	
	node.add_child(panel)
	node.add_child(button)


func _on_button_pressed(button: TextureButton) -> void:
	print(button.name + " was clicked!")
	var eqiuped_it = Database.get_equipped_item('avatar', 1)
	var eqiup = int(button.name.split("_")[1])
	if eqiuped_it.size() < 1:
		change_equipped(-1, eqiup)
	else:
		change_equipped(eqiuped_it[0]['id'], eqiup)
	$Panel2/Panel.hide()
	is_pressed = false
	update()
