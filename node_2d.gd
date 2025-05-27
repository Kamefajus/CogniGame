extends Node2D

var draggable = false
var is_inside_dropable = false
var body_ref
var offset: Vector2
var initialPos: Vector2

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Click") and draggable:
		initialPos = global_position
		offset = get_global_mouse_position() - global_position
		Global1.is_dragging = true
		Global1.current_dragged = self

	if Input.is_action_pressed("Click") and Global1.is_dragging and Global1.current_dragged == self:
		global_position = get_global_mouse_position() - offset

	if Input.is_action_just_released("Click") and Global1.is_dragging and Global1.current_dragged == self:
		Global1.is_dragging = false
		Global1.current_dragged = null

		var tween = get_tree().create_tween()
		if is_inside_dropable and not body_ref.is_occupied and body_ref.allowed_node_name == name:
			tween.tween_property(self, "position", body_ref.position, 0.2).set_ease(Tween.EASE_OUT)
			body_ref.is_occupied = true
			body_ref.current_object = self
		else:
			tween.tween_property(self, "global_position", initialPos, 0.2).set_ease(Tween.EASE_OUT)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("dropable") and not body.is_occupied and body.allowed_node_name == name:
		is_inside_dropable = true
		body.modulate = Color(Color.REBECCA_PURPLE, 1)
		body_ref = body

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == body_ref:
		is_inside_dropable = false
		body.modulate = Color(Color.MEDIUM_PURPLE, 0.7)
		body_ref = null

func _on_area_2d_mouse_entered() -> void:
	if not Global1.is_dragging:
		draggable = true
		scale = Vector2(1.05, 1.05)

func _on_area_2d_mouse_exited() -> void:
	if not Global1.is_dragging:
		draggable = false
		scale = Vector2(1, 1)
