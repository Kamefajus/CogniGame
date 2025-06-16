extends Node

@onready var http_request  : HTTPRequest = $HTTPRequest
@onready var label          : Label       = $EncouragementLabel
@onready var input_line     : LineEdit    = $InputLine
@onready var send_button    : Button      = $HelpButton
@onready var type_timer     : Timer       = $TypeTimer

var API_KEY  := "API"
var ENDPOINT := "https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent?key=%s" % API_KEY

const HINT_PROMPT := """
Tu esi draugiškas pagalbininkas pradinukų mokyklos žaidime. 
Tavo tikslas – padrąsinti vaiką ir duoti trumpą užuominą arba pagalbinį klausimą, bet NIEKADA neatskleisti teisingo atsakymo.

Taisyklės:
1. Kalbėk labai paprastai, vaikams suprantamais žodžiais.
2. Venk sudėtingų frazių, rašyk trumpai (iki 25 žodžių).
3. Visada palaikyk, pagirk už bandymą, paskatink bandyti dar.
4. Jei vaikas neprašo konkretaus atsakymo, pabandyk duoti užuominą ar pagalbinį klausimą.
5. Neatskleisk sprendimo.

Pavyzdys:
Užduotis: Surask didžiausią skaičių. 
Žaidėjo klausimas: Nežinau kuris didžiausias.
Pagalba: „Pažiūrėk į visus skaičius. Kuris atrodo didžiausias? Šaunuolis, kad klausi!“

Užduotis: %s
Žaidėjo klausimas: %s
Pagalba:
"""

enum Phase { INITIAL, WAITING_FOR_PLAYER, DONE }
var phase : int = Phase.INITIAL

var _type_text  := ""
var _type_index := 0

var _help_count : int = 0
var current_task_name : String = ""

# Paprasta dialogo istorija (paskutinės 3 žinutės)
var history : Array = []

func add_to_history(player_question: String, ai_reply: String) -> void:
	if history.size() >= 3:
		history.pop_front()
	history.append({ "player": player_question, "ai": ai_reply })

func get_history_as_text() -> String:
	var txt = ""
	for item in history:
		txt += "Žaidėjas: %s\nPagalba: %s\n" % [item["player"], item["ai"]]
	return txt

func _ready() -> void:
	http_request.connect("request_completed", Callable(self, "_on_http_request_request_completed"))
	type_timer.wait_time = 0.03
	type_timer.one_shot  = false
	type_timer.connect("timeout", Callable(self, "_on_TypeTimer_timeout"))
	_reset_help()

func set_current_task(task_name: String) -> void:
	current_task_name = task_name

func _on_help_button_pressed() -> void:
	var player_q := input_line.text.strip_edges()
	if player_q == "":
		player_q = "Man reikia pagalbos."
	_help_count += 1
	request_hint(current_task_name, player_q)

func request_hint(task: String, player_question: String) -> void:
	var prompt = HINT_PROMPT % [task, player_question]
	var hist = get_history_as_text()
	if hist != "":
		prompt = hist + "\n" + prompt
	_request_martas(prompt)

func _request_martas(prompt: String) -> void:
	var req := {
		"contents": [ { "parts": [ { "text": prompt } ] } ],
		"generationConfig": { "temperature": 0.4, "maxOutputTokens": 128 }
	}
	var err := http_request.request(
		ENDPOINT,
		["Content-Type: application/json"],
		HTTPClient.METHOD_POST,
		JSON.stringify(req)
	)
	if err != OK:
		push_error("HTTPRequest error %d" % err)

func _on_http_request_request_completed(result: int, response_code: int, _hdr, body: PackedByteArray) -> void:
	var text_out : String

	if response_code != 200:
		text_out = "Klaida! HTTP %d" % response_code
	else:
		var data = JSON.parse_string(body.get_string_from_utf8())
		if data == null or not data.has("candidates"):
			text_out = "Nepavyko gauti DI atsakymo."
		else:
			text_out = data.candidates[0].content.parts[0].text.strip_edges()
			var p = text_out.find("(")
			if p >= 0:
				text_out = text_out.substr(0, p).strip_edges()
	# Pridedam į istoriją naują žaidėjo klausimą ir DI atsakymą
	add_to_history(input_line.text.strip_edges(), text_out)
	_start_typewriter(text_out, Callable(self, "_on_followup_done"))

func _start_typewriter(text: String, done_cb: Callable) -> void:
	_type_text  = text
	_type_index = 0
	label.text  = ""
	self.set_meta("type_cb", done_cb)
	type_timer.start()

func _on_TypeTimer_timeout() -> void:
	if _type_index < _type_text.length():
		label.text += _type_text[_type_index]
		_type_index += 1
	else:
		type_timer.stop()
		var cb = self.get_meta("type_cb")
		if cb and cb is Callable:
			cb.call()

func _on_followup_done() -> void:
	phase = Phase.DONE

func _reset_help() -> void:
	_help_count = 0
	history.clear()
