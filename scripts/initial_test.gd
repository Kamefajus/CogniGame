extends Control

@onready var tab_container = $TabContainer

# Constants - Ishihara key values
const NORMAL_ANSWERS: Array[String] = ["12", "74", "6", "16", "2", "29", "7", "45", "42"]
const COLOURBLIND_ANSWERS: Array[String] = ["12", "21", "5", "15", "3", "70", "1", "17"] # plates 1-8
const PROTAN_ANSWER: String = "2"   # plate 9
const DEUTERANOPIA_ANSWER: String = "4"   # plate 9

# State variables
var my_array: Array[String] = ["", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""]
var responses: Array[String] = ["", "", "", "", "", "", "", "", ""]  # user's input for plates 1-9
var adhd_arr: Array[int] = [2, 2, 2, 3, 3, 3, 2, 2, 3, 2, 2, 3, 2, 2, 3, 2]

func _ready() -> void:
	tab_container.current_tab = 0
	_add_click_sounds_to_buttons(self)

func _add_click_sounds_to_buttons(node):
	for child in node.get_children():
		if child is Button:
			child.connect("pressed", Callable(AudioManager, "play_click"))
		elif child.get_child_count() > 0:
			_add_click_sounds_to_buttons(child)

func _on_button_pressed() -> void:
	var current_tab = tab_container.current_tab
	var line_edit = get_node("TabContainer/"+str(current_tab+1)+"/LineEdit").text.strip_edges()
	
	# Plates 1-8: compare to normal & colour-blind alternatives
	if current_tab < 8:
		if line_edit == NORMAL_ANSWERS[current_tab]:
			responses[current_tab] = "normal"
		elif line_edit == COLOURBLIND_ANSWERS[current_tab]:
			responses[current_tab] = "colourblind"
		else:
			responses[current_tab] = "wrong"
	# Plate 9 differentiates sub-types
	else:
		match line_edit:
			NORMAL_ANSWERS[8]:
				responses[current_tab] = "normal"
			PROTAN_ANSWER:
				responses[current_tab] = "Protan"
			DEUTERANOPIA_ANSWER:
				responses[current_tab] = "Deuteranopia"
			_:
				responses[current_tab] = "wrong"
	
	print("Plate %d → %s" % [current_tab + 1, responses[current_tab]])
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
	var below_cutoff := 0
	for n in 16:
		if get_score(my_array[n]) < adhd_arr[n]:
			below_cutoff += 1
	
	if below_cutoff > 9:
		print("Normal attention span")
	else:
		print("Potential ADHD")

func are_there_missing_answers() -> Array[int]:
	var miss_arr: Array[int] = []
	
	# Check Ishihara plates
	for n in 9:
		if responses[n] == "":
			miss_arr.append(n+1)
	
	# Check questionnaire pages
	for n in 6:
		if my_array[n] == "":
			miss_arr.append(10)
			break
	
	for n in range(6, 12):
		if my_array[n] == "":
			miss_arr.append(11)
			break
			
	for n in range(12, 16):
		if my_array[n] == "":
			miss_arr.append(12)
			break
	
	return miss_arr

func evaluate_vision_test() -> void:
	# Plate 1 MUST be correct, or we can't rely on anything → assume normal vision
	if responses[0] == "wrong":
		ColorProfile.mode = "normal"
		ColorProfile.apply()
		return
	
	var wrong := 0  # mis-reads (neither normal nor colour-blind)
	var cb := 0     # red-green alternative seen
	for i in range(1, 8):  # plates 2-8
		match responses[i]:
			"wrong":
				wrong += 1
			"colourblind":
				cb += 1
	
	# Too many random errors → stop, don't apply a filter
	if wrong > 2:
		ColorProfile.mode = "normal"
		ColorProfile.apply()
		return
	
	# ≥2 colour-blind readings → decide subtype from plate 9
	if cb > 1:
		match responses[8]:
			"Protan":
				ColorProfile.mode = "protanopia"
				ColorProfile.apply()
				print("protan")
			"Deuteranopia":
				ColorProfile.mode = "deuteranopia"
				ColorProfile.apply()
				print("deutan")
			_:  # unhelpful or missing answer
				ColorProfile.mode = "protanopia"
				ColorProfile.apply()
				print("protan fallback")
	else:
		ColorProfile.mode = "normal"
		ColorProfile.apply()
		print("normal")
	
	ColorProfile.apply()
