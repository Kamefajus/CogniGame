extends Panel


@export var item : Texture2D = null:
	set(value):
		item = value
		
		if value == null:
			$Icon.texture = null
			return
		
		$Icon.texture = value


@export var num : int = -1:
	set(value):
		num = value


func _get_drag_data(at_position):
	return self


func _can_drop_data(_pos, data):
	if "item" in data:
		return is_instance_of(data.item, Texture2D)
	return false


func _drop_data(_pos, data):
	var temp = item
	item = data.item
	data.item = temp
	
	temp = num
	num = data.num
	data.num = temp
