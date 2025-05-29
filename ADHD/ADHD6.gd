extends Node2D

@onready var object_container = $ObjectContainer
@onready var cover = $Cover
@onready var result_label = $Label

var original_positions = []
var swapped_nodes = []
var clicked = false

func _ready():
	randomize()
	result_label.text = ""
	cover.visible = false
	clicked = false
	
	_init_positions()
	
	print("🟢 Scena paleista")

	_save_original_positions()
	_assign_object_signals()

	await get_tree().create_timer(1.0).timeout
	_cover_objects()

	await get_tree().create_timer(1.0).timeout
	_swap_one_object()
	_uncover_objects()

func _save_original_positions():
	original_positions.clear()
	for obj in object_container.get_children():
		original_positions.append(obj.global_position)
	print("💾 Išsaugotos pozicijos:")
	for i in range(original_positions.size()):
		print("- ", object_container.get_child(i).name, ":", original_positions[i])

func _init_positions():
	var padding = 250  # tarpas tarp objektų (pikseliais)
	var current_x = -750  # pradinis x

	for obj in object_container.get_children():
		var sprite = obj.get_node("Sprite2D")  # pakeisk, jei kitas tavo sprite pavadinimas
		var width = sprite.texture.get_width() * sprite.scale.x
		
		# Poziciją nustatome pagal dabartinę current_x + pusę objekto pločio
		obj.global_position = Vector2(current_x + width / 2, 100)  # 100 - fiksuotas y koordinatės taškas

		# Atnaujinti current_x: padidinti apie objekto plotį ir tarpelį
		current_x += width + padding

func _cover_objects():
	cover.visible = true
	print("🔒 Objektai uždengti")

func _uncover_objects():
	cover.visible = false
	print("🔓 Objektai atidengti")

func _swap_one_object():
	var objs = object_container.get_children()
	if objs.size() < 2:
		return

	var index1 = randi() % objs.size()
	var index2 = (index1 + 1 + randi() % (objs.size() - 1)) % objs.size()

	var obj1 = objs[index1]
	var obj2 = objs[index2]

	print("🔄 Apsikeičia objektai:", obj1.name, "<->", obj2.name)

	var pos1 = obj1.global_position
	var pos2 = obj2.global_position

	# Sukuriamas tween'as
	var tween = create_tween()

	# Objektas 1 į objektą 2
	tween.tween_property(obj1, "global_position", pos2, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	# Objektas 2 į objektą 1
	tween.tween_property(obj2, "global_position", pos1, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	swapped_nodes = [obj1, obj2]

func _assign_object_signals():
	for obj in object_container.get_children():
		if obj.has_signal("input_event"):
			print("✅ Signalas prijungtas prie:", obj.name)
			obj.connect("input_event", Callable(self, "_on_object_clicked").bind(obj))
		else:
			print("⚠️", obj.name, "neturi input_event signalo")

func _on_object_clicked(viewport, event, shape_idx, clicked_obj):
	if clicked:
		return

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		clicked = true
		print("🖱️ Paspaustas objektas:", clicked_obj.name)

		if clicked_obj in swapped_nodes:
			result_label.text = "✅ Teisingai!"
			print("🎯 Teisingas pasirinkimas!")
		else:
			result_label.text = "❌ Neteisingai. Bandyk dar kartą!"
			print("❌ Neteisingas pasirinkimas.")
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
	get_tree().change_scene_to_file("res://ADHD/ADHD5.tscn")


func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://ADHD/ADHD7.tscn")
