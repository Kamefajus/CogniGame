extends Node2D

@onready var score_label = $UI/ScoreLabel
@onready var end_label = $UI/EndLabel
@onready var spawner = $Spawner

var score = 0
const MAX_SCORE = 5
var object_scene = preload("res://ADHD/ObjectADHD.tscn")

func _ready():
	score = 0
	score_label.text = "Taškai: 0"
	end_label.visible = false
	spawn_objects()

func update_score(value: int):
	if score >= MAX_SCORE:
		return

	score += value
	score_label.text = "Taškai: %d" % score

	clear_objects()

	if score >= MAX_SCORE:
		end_label.text = "🎉 Laimėjai! 🎉"
		end_label.visible = true
	else:
		await get_tree().create_timer(0.5).timeout
		spawn_objects()

func spawn_objects() -> void:
	clear_objects()

	var rocket_spawned = false
	var objects_to_spawn = 3

	for i in range(objects_to_spawn):
		var obj = object_scene.instantiate()
		spawner.add_child(obj)
		obj.position = Vector2(randi() % 700 + 50, randi() % 500 + 50)
		obj.main_node = self

		# Vienam iš trijų objektų priskiriam raketą
		if not rocket_spawned:
			obj.set_as_rocket(true)
			rocket_spawned = true
		else:
			obj.set_as_rocket(false)

func clear_objects():
	for obj in spawner.get_children():
		obj.queue_free()
