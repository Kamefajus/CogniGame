extends Control

var rate_sys = load("res://scripts/rating_system.gd").new()

func _ready() -> void:
	rate_sys.spawn_items($Panel/Panel2, "res://scenes/main_menu.tscn")
