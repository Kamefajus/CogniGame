extends Control

@onready var tab_container = $TabContainer

var my_array: Array[String] = ["", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""]
var normal_array = ["12", "74", "6", "16", "2", "29", "7", "45"]
var colourblind_array = ["12", "21", "5", "", "", "70", "", ""]
var answer_array = ["", "", "", "", "", "", "", "", ""]
var adhd_arr: Array[int] = [2, 2, 2, 3, 3, 3, 2, 2, 3, 2, 2, 3, 2, 2, 3, 2]

func _ready() -> void:
	tab_container.current_tab = 0


func _on_button_pressed() -> void:
	var current_tab = tab_container.current_tab
	var line_edit = get_node("TabContainer/"+str(current_tab+1)+"/LineEdit").text
	if(tab_container.current_tab < 8):
		
		if(line_edit == normal_array[current_tab]):
			answer_array[current_tab] = "normal"
		elif(line_edit == colourblind_array[current_tab]):
			answer_array[current_tab] = "colourblind"
		else:
			answer_array[current_tab] = "wrong"
		
	else:
		
		if(line_edit == "42"):
			answer_array[current_tab] = "normal"
		elif(line_edit == "4"):
			answer_array[current_tab] = "Deuteranopia"
		elif(line_edit == "2"):
			answer_array[current_tab] = "Protan"
		else:
			answer_array[current_tab] = "wrong"
	
	print(answer_array[current_tab])
	tab_container.current_tab = current_tab + 1


func _on_done_button_pressed() -> void:
	get_values_from_buttons()
	
	var miss_arr = are_there_missing_answers()
	
	if(!miss_arr.is_empty()):
		var error_message = "Neatlikti klausimai "
		error_message = error_message + str(miss_arr[0])
		
		if(miss_arr.size() == 1):
			error_message = error_message + " lange."
		else:
			for n in range(1, miss_arr.size()):
				error_message = error_message + ", "+ str(miss_arr[n])
			error_message = error_message + " languose."
		get_node("TabContainer/12/ErrorLabel").text = error_message
	else:
		evaluate_vision_test()
		evaluate_questioner_values()
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	#print(my_array)


func _on_button_1_pressed() -> void:
	tab_container.current_tab = tab_container.current_tab + 1


func get_score(answ: String) -> int:
	match answ:
		"Niekada":
			return 0
		"Retai":
			return 1
		"Kartais":
			return 2
		"Dažnai":
			return 3
		"Labai dažnai":
			return 4
		_:
			return -1


func get_values_from_buttons() -> void:
	my_array.fill("")
	print(my_array)
	var option_text = get_node("TabContainer/10/OptionButton").text
	my_array[0] = option_text
	
	for n in range(2,7):
		option_text = get_node("TabContainer/10/OptionButton"+str(n)).text
		my_array[n-1] = option_text
	
	option_text = get_node("TabContainer/11/OptionButton").text
	my_array[6] = option_text
	
	for n in range(2,7):
		option_text = get_node("TabContainer/11/OptionButton"+str(n)).text
		my_array[n+5] = option_text
	
	option_text = get_node("TabContainer/12/OptionButton").text
	my_array[12] = option_text
	
	for n in range(2,5):
		option_text = get_node("TabContainer/12/OptionButton"+str(n)).text
		my_array[n+11] = option_text


func evaluate_questioner_values() -> void:
	var cou = 0
	for n in 16:
		if(get_score(my_array[n]) < adhd_arr[n]):
			cou = cou + 1
	
	print(cou)
	
	if(cou > 9):
		print("Normal")
		return
	
	print("Adhd")


func are_there_missing_answers() -> Array[int]:
	var miss_arr: Array[int] = []
	
	for n in 9:
		if(answer_array[n] == ""):
			miss_arr.append(n+1)
		
	for n in 6:
		if(my_array[n] == ""):
			miss_arr.append(10)
			break
		
	for n in range(6, 12):
		if(my_array[n] == ""):
			miss_arr.append(11)
			break
			
	for n in range(12, 16):
		if(my_array[n] == ""):
			miss_arr.append(12)
			break
		
	return miss_arr


func evaluate_vision_test() -> void:
	if(answer_array[0] == "wrong"):
		print("Bad vision")
		return
	
	var wr_cou = 0
	var cb_cou = 0
	var n_cou = 0
	
	for n in range(1,9):
		if(answer_array[n] == "wrong"):
			wr_cou = wr_cou + 1
		elif (answer_array[n] == "normal"):
			n_cou = n_cou + 1
		else:
			cb_cou = cb_cou + 1
	
	if(wr_cou > 2):
		print("Bad vision")
		return
	
	if(cb_cou > 1):
		if(answer_array[8] == "Protan"):
			print("Protan")
			return
		
		if(answer_array[8] == "Deuteranopia"):
			print("Deuteranopia")
			return
		
		print("ColorBlind")
		return
	
	print("Normal")
