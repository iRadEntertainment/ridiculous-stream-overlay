@tool
extends EditorScript

const USERS_FOLDER_PATH = "C:/Git/TwitchStream/RidiculousStream/users/"

## Let's decide on the data structure of this mess. Should be easy
## var user_id_to_username -> {user_id (String): username (String)}
## var username_to_user_id -> {username (String): user_id (String)}
## var known_users -> {username (String): user_object (RSTwitchUser)}
##                                        OR
## var known_users -> {user_id (String): user_object (RSTwitchUser)}
##
## FILENAMES json
## file tamplate -> {user_id}_{username}.json


var user_id_to_username: Dictionary = {} # {user_id (String): username (String)}
var username_to_user_id: Dictionary = {} # {username (String): user_id (String)}
var known_users: Dictionary = {} # {username (String): user_object (RSTwitchUser)}

# user_anihanshard.json -> 1234567_anihanshard.json

# 1112233_roert_pattnsn.json -> 1112233_ropet_pattinsin.json

# 1) 12_feet_up.json -> 1112233_12_feet_up.json
# 2) 12FeetUp.json -> 1112233_12_feet_up.json

func _run() -> void:
	convert_filenames()


func convert_filenames() -> void:
	var user_id_to_files: Dictionary = {} # { user_id(int): [filenames](Array) }
	var users: Array[RSTwitchUser] = []
	var user_ids: Array[int] = []

	var user_files = RSUtl.list_file_in_folder(USERS_FOLDER_PATH, ["json"])
	# var dir := DirAccess.open(USERS_FOLDER_PATH)
	print("========== RENAMING =========")
	for user_file in user_files:
		var username = RSLoader.username_from_userfile(user_file)
		var user: RSTwitchUser = load_userfile(username, USERS_FOLDER_PATH)
		if !user:
			print("user not valid: ", user_file)
			continue
		
		var old_abs_filepath = USERS_FOLDER_PATH + user_file
		var new_abs_path = USERS_FOLDER_PATH + user_filename_json_from_user(user)
		print(old_abs_filepath, " -> ", new_abs_path)
		DirAccess.rename_absolute(old_abs_filepath, new_abs_path)

		var list: Array = user_id_to_files.get(user.user_id, [])
		user_id_to_files[user.user_id] = list + [user_file]
		
		if user_ids.has(user.user_id):
			print("Duplicated user: %s" % user_file)
			continue

		user_ids.append(user.user_id)
		users.append(user)

		# var new_user_filename = user_filename_json_from_user(user)
		# dir.rename(user_file, new_user_filename)
	
	print("---- Duplicate users -----")
	for user_id: int in user_id_to_files:
		var list: Array = user_id_to_files.get(user_id)
		if list.size() > 1:
			print(user_id, " - ", list)
			var abs_paths = []
			for filename in list:
				abs_paths.append(USERS_FOLDER_PATH + filename)
			var newest: String = get_newest_file(abs_paths)
			print("newest: %s" % newest)
			for file in abs_paths:
				if file == newest:
					continue
				print("Deleting... %s" % file)
				DirAccess.remove_absolute(file)
	
	# print("---- Saving new users -----")
	# for user: RSTwitchUser in users:
	# 	save_user_to_tres(user)

static func rename_old_to_new(from: String, to: String) -> void:
	pass


func save_user_to_tres(user: RSTwitchUser) -> void:
	var filename = user_filename_json_from_user(user)
	filename = filename.get_basename()
	filename += ".tres"
	var absolute_path = USERS_FOLDER_PATH + filename
	print(absolute_path)
	# ResourceSaver

static func get_newest_file(file_absolute_paths: Array) -> String:
	var newest_file = ""
	var latest_time = 0

	for path in file_absolute_paths:
		var modified_time = FileAccess.get_modified_time(path)
		if modified_time > latest_time:
			latest_time = modified_time
			newest_file = path

	return newest_file


# 583436095 - ["user_12feetup.json", "user_12_feet_up.json"]
# 28582061 - ["user_almostbiley.json", "user_bileyraker.json"]
# 947660686 - ["user_codespace0x25.json", "user_codevoid0x25.json"]
# 499309619 - ["user_factoryresetem.json", "user_xxfactory_resetxx.json"]
# 516236177 - ["user_finisfine.json", "user_finsiftycat.json"]
# 14028591 - ["user_icy_april_dawn.json", "user_icy_the_icy_squirrel.json"]
# 96173682 - ["user_justin_helps.json", "user_primerjustin.json"]
# 207844386 - ["user_kamilos_eu.json", "user_kvmilos.json"]
# 96261252 - ["user_quellus.json", "user_quellusdev.json"]
# 183472829 - ["user_roertpattnsn.json", "user_rortpahinsn.json"]
# 22384402 - ["user_schepeis.json", "user_skepays.json"]



func test_filenames_and_users() -> void:
	known_users = load_all_users()
	
	for user: RSTwitchUser in known_users.values():
		var test_filename = user_filename_json_from_user(user)
		var test_user_id_from_filename = user_id_from_filename(test_filename)
		var test_username_from_filename = username_from_filename(test_filename)
		
		if user.user_id != test_user_id_from_filename:
			print("WRONG USER ID: ", user.username)
		if user.username != test_username_from_filename:
			print("WRONG USERNAME: ", user.username)
		
		print("%s -> User ID: %s | Username: %s" % [test_filename, test_user_id_from_filename, test_username_from_filename])
	
	print("Test finished")
	#var user_files = RSUtl.list_file_in_folder(USERS_FOLDER_PATH, ["json"])


static func user_filename_basename_from_user(user: RSTwitchUser) -> String:
	var dic: Dictionary = {"user_id": user.user_id, "username": user.username}
	return "{user_id}_{username}".format(dic)
static func user_filename_json_from_user(user: RSTwitchUser) -> String:
	return user_filename_basename_from_user(user) + ".json"
static func user_filename_tres_from_user(user: RSTwitchUser) -> String:
	return user_filename_basename_from_user(user) + ".tres"
static func username_from_filename(user_filename: String) -> String:
	var no_extension = user_filename.get_file().get_basename()
	return no_extension.split("_", false, 1)[1]
static func user_id_from_filename(user_filename: String) -> int:
	var no_extension = user_filename.get_file().get_basename()
	return int(no_extension.split("_", false, 1)[0])
static func rename_file(absolute_path: String, new_absolute_path: String) -> void:
	DirAccess.rename_absolute(absolute_path, new_absolute_path)


func load_all_users() -> Dictionary:
	var dic = {}
	var user_files = RSUtl.list_file_in_folder(USERS_FOLDER_PATH, ["json"])
	
	for user_file in user_files:
		var username = RSLoader.username_from_userfile(user_file)
		var res: RSTwitchUser = load_userfile(username, USERS_FOLDER_PATH)
		if res:
			dic[username] = res
	
	return dic


static func load_userfile(username: String, user_folder_path: String) -> RSTwitchUser:
	var path := RSLoader.get_user_filepath(username, user_folder_path)
	if !FileAccess.file_exists(path):
		print_verbose("Cannot find file: %s" % path)
		return null
	var user := RSTwitchUser.from_json(RSUtl.load_json(path))
	return user


func convert_all_users():
	var dic = {}
	var user_files = RSUtl.list_file_in_folder(RSSettings.get_users_path(), ["tres"])
	
	for user_file in user_files:
		var path = RSSettings.get_users_path() + user_file
		var username = RSLoader.username_from_userfile(user_file)
		var res = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE) as RSTwitchUser
		if res.username:
			pass
			# print("user loaded OK: ", res.username)
		else:
			print("user missing info: ", username)
		dic[username] = {"RSTwitchUser": res, "path": path}

	for username in dic.keys():
		var res := dic[username]["RSTwitchUser"] as RSTwitchUser
		var path := dic[username]["path"] as String
		path = path.trim_suffix("tres") + "json"
		RSUtl.save_to_json(path, res.to_dict())
