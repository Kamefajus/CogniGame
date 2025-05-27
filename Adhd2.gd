extends Node2D

@onready var star_area = $Area2D
@onready var star = $Area2D/Star
@onready var objects = [ $Object1, $Object2, $Object3, $Object4 ]
@onready var label = $Label

func _ready():
	randomize()
	label.text = "Surask žvaigždę!"
	_place_star_and_objects()
	star_area.connect("input_event", Callable(self, "_on_star_clicked"))

func _place_star_and_objects():
	var positions = []
	for i in range(6):  # 1 žvaigždė + 5 objektai
		positions.append(Vector2(randi() % 800, randi() % 600))

	star_area.position = positions.pop_back()

	for obj in objects:
		obj.position = positions.pop_back()

func _on_star_clicked(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		label.text = "Radai žvaigždę!"
		label.add_theme_color_override("font_color", Color.GREEN)
