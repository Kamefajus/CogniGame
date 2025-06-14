extends TextureRect

var is_dragging := false
var start_position: Vector2
var current_drop_zone: Control = null
var allowed_drop_zone: String = ""
var is_in_correct_zone := false
var is_in_any_zone := false
var original_position: Vector2

func _ready():
	original_position = position
	match name:
		"DraggableItem1": allowed_drop_zone = "DropZone3"
		"DraggableItem2": allowed_drop_zone = "DropZone1"
		"DraggableItem3": allowed_drop_zone = "DropZone2"
	
	add_to_group("draggables")
	gui_input.connect(_on_gui_input)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and not is_dragging:
			# Start drag
			is_dragging = true
			start_position = position
			move_to_front()
			
			# Clear from current drop zone if needed
			if current_drop_zone:
				current_drop_zone.is_occupied = false
				current_drop_zone.current_item = null
				current_drop_zone.update_appearance()
				current_drop_zone = null
			
			is_in_any_zone = false
			is_in_correct_zone = false

		elif is_dragging and not event.pressed:
			# End drag
			is_dragging = false
			var tween = create_tween()
			
			if current_drop_zone and not current_drop_zone.is_occupied:
				# Snap to drop zone
				tween.tween_property(self, "global_position", current_drop_zone.global_position, 0.2)
				current_drop_zone.is_occupied = true
				current_drop_zone.current_item = self
				is_in_any_zone = true
				is_in_correct_zone = (current_drop_zone.name == allowed_drop_zone)
				current_drop_zone.update_appearance()
			else:
				# Invalid drop, return to original position
				tween.tween_property(self, "position", original_position, 0.2)
				is_in_any_zone = false
				is_in_correct_zone = false
				current_drop_zone = null
			
			# Check win condition
			get_tree().call_group("game_controller", "check_win_condition")

	if is_dragging and event is InputEventMouseMotion:
		position += event.relative
		_check_drop_zones()

func _check_drop_zones():
	var new_drop_zone = null

	for zone in get_tree().get_nodes_in_group("drop_zones"):
		if _is_overlapping(zone) and (not zone.is_occupied or zone.current_item == self):
			new_drop_zone = zone
			break

	if new_drop_zone != current_drop_zone:
		if current_drop_zone:
			current_drop_zone.update_appearance()
		current_drop_zone = new_drop_zone
		if current_drop_zone:
			current_drop_zone.update_appearance()

func _is_overlapping(zone: Control) -> bool:
	var my_rect = Rect2(global_position, size)
	var zone_rect = Rect2(zone.global_position, zone.size)
	return my_rect.intersects(zone_rect)

func _on_mouse_entered():
	if !is_dragging:
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.1)

func _on_mouse_exited():
	if !is_dragging:
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
