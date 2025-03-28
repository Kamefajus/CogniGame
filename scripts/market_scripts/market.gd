extends Control

@onready var money_label = $ColorRect/Label
var money = 150
var temp_id = -1
var u_id = 1

signal update(change: bool)

func _ready() -> void:
	Database._ready()
	money_label.text = str(money)


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_avatarai_update_money(id: int) -> void:
	var cost = Database.get_iten_price_by_id(id)
	if cost <= money:
		$Panel2.show()
		temp_id = id
	else:
		emit_signal("update", false)


func _on_no_button_pressed() -> void:
	temp_id = -1
	$Panel2.hide()
	emit_signal("update", false)


func _on_yes_button_pressed() -> void:
	var cost = Database.get_iten_price_by_id(temp_id)
	if cost > 0:
		money = money - cost
		money_label.text = str(money)
		$Panel2.hide()
		Database.insert_owned_item(1, temp_id)
		temp_id = -1
		emit_signal("update", true)
