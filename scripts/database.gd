extends Node

var db

func _ready():
	db = SQLite.new()
	var path = "user://user_data.db"
	db.path = path
	if db.open_db():
		print("Database opened successfully.")
	else:
		print("Failed to open database: ", db.get_last_error_message())
		return
	
	# Create the users table if it doesn't exist
	var create_table_query = """
		CREATE TABLE IF NOT EXISTS users (
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			name TEXT NOT NULL,
			nickname TEXT UNIQUE NOT NULL,
			email TEXT UNIQUE NOT NULL,
			password TEXT NOT NULL
		);
	"""
	if db.query(create_table_query):
		print("Users table ensured.")
	else:
		print("Error creating table: ", db.get_last_error_message())

# Register a new user
func register_user(name: String, nickname: String, email: String, password: String) -> bool:
	var check_query = "SELECT * FROM users WHERE nickname = ? OR email = ?;"
	if db.query_with_bindings(check_query, [nickname, email]):
		if db.query_result.size() > 0:
			print("Nickname or email already exists.")
			return false
	else:
		print("Error checking existing user: ", db.get_last_error_message())
		return false

	var insert_query = "INSERT INTO users (name, nickname, email, password) VALUES (?, ?, ?, ?);"
	if db.query_with_bindings(insert_query, [name, nickname, email, password]):
		print("User registered successfully.")
		return true
	else:
		print("Error inserting user: ", db.get_last_error_message())
		return false

func verify_login(nickname: String, password: String) -> bool:
	var login_query = "SELECT * FROM users WHERE nickname = ? AND password = ?;"
	if db.query_with_bindings(login_query, [nickname, password]):
		if db.query_result.size() > 0:
			print("Login successful!")
			return true
		else:
			print("Invalid credentials!")
			return false
	else:
		print("Error checking login: ", db.get_last_error_message())
		return false

func verify_email(email: String) -> bool:
	var login_query = "SELECT * FROM users WHERE email = ?;"
	if db.query_with_bindings(login_query, [email]):
		if db.query_result.size() > 0:
			print("Email verification successful!")
			return true
		else:
			print("Email verification failed!")
			return false
	else:
		print("Error checking login: ", db.get_last_error_message())
		return false


func update_user_password(email: String, password: String) -> bool:
	var insert_query = "UPDATE users SET password = ? WHERE email = ?;"
	if db.query_with_bindings(insert_query, [password, email]):
		print("User registered successfully.")
		return true
	else:
		print("Error inserting user: ", db.get_last_error_message())
		return false
