@tool
extends EditorScript

const USERS_FOLDER_PATH = "C:/Git/TwitchStream/RidiculousStream/users/"


var user_id_to_username: Dictionary = {} # {user_id (String): username (String)}
var username_to_user_id: Dictionary = {} # {username (String): user_id (String)}
var known_users: Dictionary = {} # {username (String): user_object (RSUser)}

# user_anihanshard.json -> 1234567_anihanshard.json

# 1112233_roert_pattnsn.json -> 1112233_ropet_pattinsin.json

# 1) 12_feet_up.json -> 1112233_12_feet_up.json
# 2) 12FeetUp.json -> 1112233_12_feet_up.json

func _run() -> void:
	convert_filenames()


func convert_filenames() -> void:
	var user_id_to_files: Dictionary = {} # { user_id(int): [filenames](Array) }
	var users: Array[RSUser] = []
	var user_ids: Array[int] = []

	var user_files = RSUtl.list_file_in_folder(USERS_FOLDER_PATH, ["json"])
	# var dir := DirAccess.open(USERS_FOLDER_PATH)
	for user_file in user_files:
		# var username = RSUserMng.username_from_filename(user_file)
		var user: RSUser = RSUserMng.load_user_from_json(USERS_FOLDER_PATH + user_file)
		if !user:
			print("user not valid: ", user_file)
			continue

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
			var newest: String = RSUtl.get_newest_file(abs_paths)
			print("newest: %s" % newest)
			for file in abs_paths:
				if file == newest:
					continue
				print("Deleting... %s" % file)
				DirAccess.remove_absolute(file)
	
	# print("---- Saving new users -----")
	# for user: RSUser in users:
	# 	save_user_to_tres(user)


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
	known_users = RSUserMng.load_all_users_from_folder(USERS_FOLDER_PATH)
	
	for user: RSUser in known_users.values():
		var test_filename = RSUserMng.user_filename_json_from_user(user)
		var test_user_id_from_filename = RSUserMng.user_id_from_filename(test_filename)
		var test_username_from_filename = RSUserMng.username_from_filename(test_filename)
		
		if user.user_id != test_user_id_from_filename:
			print("WRONG USER ID: ", user.username)
		if user.username != test_username_from_filename:
			print("WRONG USERNAME: ", user.username)
		
		print("%s -> User ID: %s | Username: %s" % [test_filename, test_user_id_from_filename, test_username_from_filename])
	
	print("Test finished")
	#var user_files = RSUtl.list_file_in_folder(USERS_FOLDER_PATH, ["json"])


func convert_all_users():
	var dic = {}
	var user_files = RSUtl.list_file_in_folder(RSSettings.get_users_path(), ["tres"])
	
	for user_file in user_files:
		var path = RSSettings.get_users_path() + user_file
		var username = RSUserMng.username_from_filename(user_file)
		var res = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE) as RSUser
		if res.username:
			pass
			# print("user loaded OK: ", res.username)
		else:
			print("user missing info: ", username)
		dic[username] = {"RSUser": res, "path": path}

	for username in dic.keys():
		var res := dic[username]["RSUser"] as RSUser
		var path := dic[username]["path"] as String
		path = path.trim_suffix("tres") + "json"
		RSUtl.save_to_json(path, res.to_dict())
