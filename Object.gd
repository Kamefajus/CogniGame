extends Area2D

@onready var sprite = $Sprite2D
@onready var shape = $CollisionShape2D

var is_rocket = false
var main_node = null

func _ready():
	input_pickable = true
	shape.disabled = false

	# Atsitiktinai parenkam ar raketa, ar apskritimas
	if randf() < 0.5:
		sprite.texture = preload("res://May 20, 2025, 05_29_39 PM.png")
		is_rocket = true
	else:
		sprite.texture = preload("res://Red-Circle-Transparent.png")
		is_rocket = false

func _input_event(viewport, event, shape_idx):
	print("PASPAUSTA!")
	if event is InputEventMouseButton and event.pressed:
		if main_node:
			if is_rocket:
				main_node.update_score(1)
			else:
				main_node.update_score(-1)
		queue_free()
