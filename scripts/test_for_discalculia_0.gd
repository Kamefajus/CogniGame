extends Control

var apple_number
var clock_number
var big_number
var temp_number = 0
var correct = 0

func _ready() -> void:
	apple_number = randi_range(1, 20)
	Generate_apple_calculation_task(apple_number)
	clock_number = randi_range(0, 10)
	clock_number = Generate_clook_task(clock_number)
	big_number = randi_range(1, 9999)
	Generate_number_task(big_number)
	Generate_numbers_low_to_high()


func Generate_apple_calculation_task(random_number: int):
	var positions = [
		Vector2(552, 271), Vector2(184, 132), Vector2(282, 107),
		Vector2(85, 166), Vector2(154, 181), Vector2(635, 267),
		Vector2(397, 277), Vector2(218, 210), Vector2(641, 139),
		Vector2(708, 211), Vector2(477, 118), Vector2(341, 238),
		Vector2(422, 175), Vector2(557, 189), Vector2(467, 248),
		Vector2(368, 114), Vector2(282, 171), Vector2(126, 249),
		Vector2(223, 272), Vector2(552, 108)
		 ]
	
	positions.shuffle()
	
	var selected = positions.slice(0, random_number)
	
	var apple_image = preload("res://assets/red-apple-generative-ai-png.webp")
	
	for apple in selected:
		var new_apple = Sprite2D.new()
		new_apple.texture = apple_image
		new_apple.position = apple
		new_apple.scale = Vector2(0.1, 0.1)
		$"Panel/Panel2/TabContainer/1".add_child(new_apple)


func Generate_clook_task(random_number: int):
	var clocks = [ "1", "2", "3", "4", "5", "6", "8", "9", "10", "11", "12"]
	
	var picked = clocks[random_number]
	
	var text = $"Panel/Panel2/TabContainer/9/Label".text +" "+ picked + ":00?"
	$"Panel/Panel2/TabContainer/9/Label".text = text
	
	clocks.erase(picked)
	clocks.shuffle()
	var picked_clocks = clocks.slice(0, 4)
	
	picked_clocks.append(picked)
	picked_clocks.shuffle()
	
	var indx = 0
	var res = -1
	
	for clock in picked_clocks:
		var clock_image = load("res://assets/clocks/Clock_"+clock+"_00.png")
		var new_clock = Sprite2D.new()
		new_clock.position = Vector2(136 + 130*(indx), 200)
		new_clock.texture = clock_image
		new_clock.name = "S" + str(indx)
		if clock == picked:
			res = indx
		
		var check = CheckBox.new()
		check.name = "CheckBox" + str(indx)
		check.position = Vector2(132 +130*(indx), 275)
		indx = indx + 1
		
		$"Panel/Panel2/TabContainer/9".add_child(new_clock)
		$"Panel/Panel2/TabContainer/9".add_child(check)
	
	return res


func Generate_number_task(random_number: int):
	$"Panel/Panel2/TabContainer/4/Number".text = str(random_number)
	
	add_button_events($"Panel/Panel2/TabContainer/4/VBoxContainer1")
	add_button_events($"Panel/Panel2/TabContainer/4/VBoxContainer2")
	add_button_events($"Panel/Panel2/TabContainer/4/VBoxContainer3")
	add_button_events($"Panel/Panel2/TabContainer/4/VBoxContainer4")


func Generate_numbers_low_to_high():
	var num = [ "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
	num.shuffle()
	var picked_num = num.slice(0, 5)
	var sl_nr = 1
	var tab = $"Panel/Panel2/TabContainer/2"
	for i in picked_num:
		var texture: Texture2D = load("res://assets/number/num"+i+".png")
		tab.find_child("Slot0"+str(sl_nr)).item = texture
		tab.find_child("Slot0"+str(sl_nr)).num = int(i)
		sl_nr = sl_nr + 1


func add_button_events(node):
	for child in node.get_children():
		if child is Button:
			child.pressed.connect(func(): _on_texture_button_pressed(child))
			child.get_child(0).mouse_filter = Control.MOUSE_FILTER_PASS


func _on_button_pressed() -> void:
	var tab_container = $"Panel/Panel2/TabContainer"
	var current_tab = tab_container.current_tab
	tab_container.current_tab = current_tab + 1


func Check_if_correct(tab: int, indx: int = 0):
	match tab:
		1:
			if apple_number == int($"Panel/Panel2/TabContainer/1/LineEdit".text):
				correct = correct + 1
		2:
			var tab2 = $"Panel/Panel2/TabContainer/2"
			var is_corr = true
			for i in range(1,5):
				var num = tab2.find_child("Slot0"+str(i)).num
				var num1 = tab2.find_child("Slot0"+str(i+1)).num
				if(num > num1):
					is_corr = false
			if is_corr:
				correct = correct + 1
		3:
			if 25 == int($"Panel/Panel2/TabContainer/3/LineEdit".text):
				correct = correct + 1
		4:
			if big_number == temp_number:
				correct = correct + 1
		5:
			if 8 == int($"Panel/Panel2/TabContainer/5/LineEdit".text):
				correct = correct + 1
		6:
			if 3 == int($"Panel/Panel2/TabContainer/6/LineEdit".text):
				correct = correct + 1
		7:
			var tab7 = $"Panel/Panel2/TabContainer/7"
			var corr_array = [true, true, false, false, true]
			var is_corr = true
			for i in range(1,6):
				var temp = tab7.find_child("CheckBox"+str(i)).button_pressed
				
				if(temp != corr_array[i-1]):
					is_corr = false
			if is_corr:
				print("temp")
				correct = correct + 1
		8:
			var tab8 = $"Panel/Panel2/TabContainer/8"
			var corr_array = [false, false, false, true]
			var is_corr = true
			for i in range(1,5):
				var temp = tab8.find_child("CheckBox"+str(i)).button_pressed
				
				if(temp != corr_array[i-1]):
					is_corr = false
			if is_corr:
				print("temp")
				correct = correct + 1
		9:
			var tab9 = $"Panel/Panel2/TabContainer/9"
			var is_corr = false
			for i in range(0,5):
				var temp_s = tab9.get_node("S"+str(i))
				var temp_ch = tab9.get_node("CheckBox"+str(i))
				if temp_ch.button_pressed:
					if temp_ch.name.split("CheckBox")[1] == str(indx):
						is_corr = true
					else:
						is_corr = false
						break
			
			if is_corr:
				correct = correct + 1


func _on_button_last_pressed() -> void:
	for i in range(1,9):
		Check_if_correct(i)
	Check_if_correct(9, clock_number)
	$Panel/Panel2/TabContainer.visible = false
	Show_how_correct(correct, $Panel/Panel2)
	var rate_sys = load("res://scripts/rating_system.gd").new()
	rate_sys.spawn_items($Panel/Panel2, "res://scenes/main_menu.tscn", Color.BLACK)


func _on_texture_button_pressed(button: Button):
	var number = int(button.name.split("ButNum")[1])
	var child = button.get_child(0)
	var current_color = child.color
	var len = button.name.split("ButNum")[1].length()
	var nth_digit = get_nth_digit(temp_number, len - 1)
	print(nth_digit)
	if current_color.a < 1.0:
		current_color.a = 1.0
		temp_number = temp_number - number
	else:
		current_color.a = 0.5
		if nth_digit > 0:
			var button_name = "ButNum"+str(nth_digit)+"0".repeat(len-1)
			var tem_color = button.get_parent().find_child(button_name).get_child(0).color
			tem_color.a = 1.0
			button.get_parent().find_child(button_name).get_child(0).color = tem_color
			temp_number = temp_number - nth_digit * 10 ** (len-1)
		temp_number = temp_number + number
	child.color = current_color
	print(temp_number)


func get_nth_digit(number: int, n: int) -> int:
	var num_str = str(number)
	if n >= 0 and n < num_str.length():
		return int(num_str[num_str.length()-n-1])
	else:
		return -1


func Show_how_correct(number: int, root: Node):
	var correctness_label = Label.new()
	correctness_label.text = "Teisingi atsakymai"
	correctness_label.add_theme_font_size_override("font_size", 32)
	correctness_label.position = Vector2(255, 25)
	
	var how_correct_label = Label.new()
	how_correct_label.text = str(number) + "/9"
	how_correct_label.position = Vector2(380, 80)
	how_correct_label.add_theme_font_size_override("font_size", 25)
	
	var coin_label = Label.new()
	coin_label.text = "+" + str(number * 5)
	print(coin_label.size)
	coin_label.position = Vector2(370, 113)
	coin_label.add_theme_font_size_override("font_size", 22)
	coin_label.add_theme_color_override("font_color", Color.BLACK)
	
	var panel = Panel.new()
	panel.size = Vector2(22, 22)
	panel.position = Vector2(410, 119)
	
	var stylebox = StyleBoxTexture.new()
	stylebox.texture = load("res://assets/pngimg.com - coin_PNG36871.png")
	panel.add_theme_stylebox_override("panel", stylebox)
	
	var color
	if 4 < number:
		color = Color.DARK_GREEN
	else:
		color = Color.CRIMSON
	
	how_correct_label.add_theme_color_override("font_color", color)
	correctness_label.add_theme_color_override("font_color", color)
	
	root.add_child(correctness_label)
	root.add_child(how_correct_label)
	root.add_child(coin_label)
	root.add_child(panel)
	
	var id = Database.curr_uid
	var curr_money = Database.get_user_money_amount(1)
	Database.update_user_money_amount(1, curr_money + number * 5)
