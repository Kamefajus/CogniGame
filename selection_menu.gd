extends Control


func _on_texture_button_pressed() -> void:
	SceneTransition.change_scene("res://scenes/Games/Snake.tscn")


func _on_texture_button_2_pressed() -> void:
	SceneTransition.change_scene("res://scenes/Games/tetris.tscn")


func _on_texture_button_3_pressed() -> void:
	SceneTransition.change_scene("res://scenes/test_for_discalculia_0.tscn")

func _on_texture_button_4_pressed() -> void:
	SceneTransition.change_scene("res://test_for_ADHD.tscn")

func _on_texture_button_5_pressed() -> void:
	SceneTransition.change_scene("res://test_for_ColorBlindness.tscn")

func _on_next_button_pressed() -> void:
	SceneTransition.change_scene("res://scenes/main_menu.tscn")
