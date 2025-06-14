extends Node

var db
var curr_uid = -1

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
		
	var create_table_query_1 = """
		CREATE TABLE IF NOT EXISTS users_items (
			user_id INTEGER NOT NULL,
			item_id INTEGER NOT NULL,
			is_equipped BOOLEAN NOT NULL,
			PRIMARY KEY (user_id, item_id),
			FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
			FOREIGN KEY (item_id) REFERENCES items(id) ON DELETE CASCADE
		);
	"""
	
	if db.query(create_table_query_1):
		print("Users items table ensured.")
	else:
		print("Error users items creating table: ", db.query_errors)
	
	var create_table_query_2 = """
		CREATE TABLE IF NOT EXISTS items (
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			name TEXT NOT NULL,
			type TEXT NOT NULL,
			asset TEXT NOT NULL,
			price INTEGER NOT NULL DEFAULT 0
		);
	"""
	
	if db.query(create_table_query_2):
		print("Items table ensured.")
	else:
		print("Error items creating table: ", db.query_errors)


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


func get_items_by_category(category: String):
	var item_query = "SELECT * FROM items WHERE type = ?
					  ORDER by id;"
	var items = []
	if db.query_with_bindings(item_query, [category]):
		for row in db.query_result:
			var item = {
				"id": row["id"],
				"name": row["name"],
				"asset": row["asset"],
				"price": row["price"]
			}
			items.append(item)
		print("Items got succesfuly.")
		return items
	else:
		print("Error retreving items: ", db.get_last_error_message())
		return items


func get_owened_items_by_user(category: String, user_id: int):
	var item_query = "SELECT items.id, items.name, items.asset FROM users_items
					  JOIN items ON items.id = users_items.item_id
					  WHERE users_items.user_id = ? AND  items.type = ?
					  ORDER by items.id;"
	var items = []
	if db.query_with_bindings(item_query, [user_id, category]):
		for row in db.query_result:
			var item = {
				"id": row["id"],
				"name": row["name"],
				"asset": row["asset"]
			}
			items.append(item)
		print("Items got succesfuly.")
		return items
	else:
		print("Error retreving items: ", db.get_last_error_message())
		return items


func get_iten_price_by_id(id: int) -> int:
	var item_query = "SELECT price FROM items WHERE id = ?"
	if db.query_with_bindings(item_query, [id]):
		return db.query_result[0]['price']
	else:
		print("Error retreving items: ", db.get_last_error_message())
		return -1


func insert_owned_item(u_id: int, it_id: int) -> void:
	var item_query = "INSERT INTO users_items (user_id, item_id, is_equipped)
					  VALUES (?, ?, false);"
	if db.query_with_bindings(item_query, [u_id, it_id]):
		print("purchesed successfully.")
	else:
		print("Error retreving items: ", db.get_last_error_message())


func get_equipped_item(category: String, user_id: int):
	var item_query = "SELECT items.id, items.name, items.asset FROM users_items 
		JOIN items ON items.id = users_items.item_id
		WHERE users_items.user_id = ? AND  items.type = ? AND is_equipped = TRUE;"
	if db.query_with_bindings(item_query, [user_id, category]):
		return db.query_result
	else:
		print("Error retreving items: ", db.get_last_error_message())
		return db.query_result
	
	
func change_equipped_item(item_id: int, user_id: int) -> void:
	var item_query = "UPDATE users_items SET is_equipped = NOT is_equipped
					  WHERE user_id = ? AND item_id = ?;"
	if db.query_with_bindings(item_query, [user_id, item_id]):
		print("changed item")
	else:
		print("Error retreving items: ", db.get_last_error_message())


func login_user(uid: int) -> void:
	curr_uid = uid


func get_user_id(nickname: String) -> int:
	var insert_query = "SELECT users.id FROM users WHERE users.nickname = ?;"
	if db.query_with_bindings(insert_query, [nickname]):
		#print("User found")
		return db.query_result[0]['id']
	else:
		print("Error inserting user: ", db.get_last_error_message())
		return -1


func get_user_money_amount(uid: int) -> int:
	var insert_query = "SELECT users.cions FROM users WHERE users.id = ?;"
	if db.query_with_bindings(insert_query, [uid]):
		return db.query_result[0]['cions']
	else:
		print("Error inserting user: ", db.get_last_error_message())
		return -1


func update_user_money_amount(uid: int, money: int) -> bool:
	var update_query = "UPDATE users SET cions = ? WHERE id = ?;"
	if db.query_with_bindings(update_query, [money, uid]):
		return true
	else:
		print("Error inserting user: ", db.get_last_error_message())
		return false
