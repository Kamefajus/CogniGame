extends TabBar

var node
var u_id = 1
var market_tab = load("res://scripts/market_scripts/market_tab.gd").new(self)
var is_clear = true

signal update_money(id: int)

func _ready() -> void:
	market_tab.update(u_id, "avatar")


func _process(delta: float) -> void:
	$RichTextLabel/Node2D.position.y = -$VScrollBar.value


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				$VScrollBar.value = $VScrollBar.value + 10
			elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
				$VScrollBar.value = $VScrollBar.value - 10


func _on_button_pressed(button: Button) -> void:
	print(button.name + " was clicked!")
	if is_clear:
		is_clear = false
		emit_signal("update_money", int(button.name.split("_")[1]))


func _on_market_update(change: bool) -> void:
	if change:
		market_tab.update(u_id, "avatar")
		is_clear = true
	else:
		is_clear = true
