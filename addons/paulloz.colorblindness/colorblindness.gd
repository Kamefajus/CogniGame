@tool
@icon("res://addons/paulloz.colorblindness/colorblindness.svg")
class_name Colorblindness
extends CanvasLayer

enum TYPE { None, Protanopia, Deuteranopia, Tritanopia, Achromatopsia }
@export var Type : TYPE = TYPE.None:
	set(value):
		if rect.material:
			rect.material.set_shader_parameter("type", value)
		else:
			temp = value
		Type = value

var temp : int = -1
var rect : ColorRect = ColorRect.new()

# ------------------------------------------------------------------
func _ready() -> void:
	add_child(rect)

	# make the ColorRect ALWAYS cover the whole viewport
	rect.anchor_left   = 0
	rect.anchor_top    = 0
	rect.anchor_right  = 1
	rect.anchor_bottom = 1
	rect.offset_left   = 0
	rect.offset_top    = 0
	rect.offset_right  = 0
	rect.offset_bottom = 0

	rect.material = load("res://addons/paulloz.colorblindness/colorblindness.material")
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

	if temp != -1:
		Type = temp
		temp = -1
