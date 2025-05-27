extends Area2D

@onready var sprite = $Sprite2D
@onready var shape = $CollisionShape2D

var is_rocket = false
var main_node = null

func _ready():
	input_pickable = true
	shape.disabled = false

func set_as_rocket(is_rocket_value: bool) -> void:
	is_rocket = is_rocket_value
	if is_rocket:
		sprite.texture = preload("res://May 20, 2025, 05_29_39 PM.png")
	else:
		sprite.texture = preload("res://Red-Circle-Transparent.png")

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if main_node:
			if is_rocket:
				main_node.update_score(1)
			else:
				main_node.update_score(-1)
		queue_free()
