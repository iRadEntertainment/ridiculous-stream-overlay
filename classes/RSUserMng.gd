extends Node
class_name RSUserMng

static var l: RSLogger

## FILENAMES json
## file tamplate -> {user_id}_{username}.json

var known := {} # {user_id (int): user_object (RSTwitchUser)}
var unknown := {} # {user_id (int): user_object (RSTwitchUser)}
var username_to_user_id := {} # -> {username (String): user_id (int)} # used for known and cached unknown


func start():
	RSUserMng.l = RSLogger.new(RSSettings.LOGGER_NAME_USER_MNG)
	l.i("Started")
	l.i("Loading all users")
	known = load_all_users_from_folder(RSSettings.get_users_path())


func save_all() -> void:
	l.i("Saving all users")
	save_all_users_to_folder(known, RSSettings.get_users_path())


# UTILITIES
func get_user_from_username(username : String) -> RSTwitchUser:
	var user: RSTwitchUser
	var user_id: int = 0
	if username in username_to_user_id.keys():
		user_id = username_to_user_id[username]
		user = await get_user_from_user_id(user_id)
	else:
		user = await user_from_twitch_api(username)
	return user
	

func get_user_from_user_id(user_id : int) -> RSTwitchUser:
	var user: RSTwitchUser
	if known.has(user_id):
		user = known[user_id]
	elif unknown.has(user_id):
		user = unknown[user_id]
	else:
		user = await user_from_twitch_api("", user_id)
	return user


func user_from_twitch_api(username: String = "", user_id: int = 0) -> RSTwitchUser:
	var t_user : TwitchUser
	if !username.is_empty():
		t_user = await RS.twitcher.get_user(username)
	elif user_id != 0:
		t_user = await RS.twitcher.get_user_by_id(str(user_id))
	if not t_user:
		return null
	
	var user := RSTwitchUser.new()
	user = RSTwitchUser.from_twitcher_user(t_user)
	user.twitch_chat_color = await RS.twitcher.get_user_color(t_user.id)
	if known.has(user.user_id):
		known[user.user_id] = user
	else:
		unknown[user.user_id] = user
	return user


func is_user_known(user: RSTwitchUser) -> bool:
	return known.has(user.user_id)
func is_username_known(username: String) -> bool:
	if username_to_user_id.has(username):
		var user_id = username_to_user_id[username]
		return is_user_id_known(user_id)
	return false
func is_user_id_known(user_id: int) -> bool:
	return known.has(user_id)

# STATIC METHODS
static func load_all_users_from_folder(user_folder: String) -> Dictionary:
	var dic: Dictionary = {}
	var user_files = RSUtl.list_file_in_folder(user_folder, ["json"])
	
	for user_file in user_files:
		var abs_path = user_folder + user_file
		var user_dic: Dictionary = RSUtl.load_json(abs_path)
		var user: RSTwitchUser = RSTwitchUser.from_json(user_dic)
		dic[user.user_id] = user
	return dic

static func save_all_users_to_folder(users_dic: Dictionary, user_folder: String) -> void:
	for user: RSTwitchUser in users_dic.values():
		save_user_to_json(user, user_folder)

static func load_user_from_json(path: String) -> RSTwitchUser:
	if !FileAccess.file_exists(path):
		l.e("Cannot find file: %s" % path)
		return null
	var user_dic: Dictionary = RSUtl.load_json(path)
	var user := RSTwitchUser.from_json(user_dic)
	return user
static func save_user_to_json(user: RSTwitchUser, user_folder: String) -> void:
	if user.username == "":
		print_verbose("cannot save an user without a username")
		return
	var abs_path = user_folder + user_filename_json_from_user(user)
	var dict = user.to_dict()
	if not dict.is_empty():
		RSUtl.save_to_json(abs_path, dict)
	else:
		l.e("Failed to save user. Missing data.")


# static func load_user_from_file_by_username(username: String, user_folder: String) -> RSTwitchUser:
# 	var path := get_user_filepath(username, user_folder)
# 	if user.username == "":
# 		user.username = username_from_userfile(path)
# 		l.e("%s doesn't contain a username." % path.get_file())
# 	return user

static func user_filename_basename_from_user(user: RSTwitchUser) -> String:
	var dic: Dictionary = {"user_id": user.user_id, "username": user.username}
	return "{user_id}_{username}".format(dic)
static func user_filename_json_from_user(user: RSTwitchUser) -> String:
	return user_filename_basename_from_user(user) + ".json"
# static func user_filename_tres_from_user(user: RSTwitchUser) -> String:
# 	return user_filename_basename_from_user(user) + ".tres"
static func username_from_filename(user_filename: String) -> String:
	var no_extension = user_filename.get_file().get_basename()
	return no_extension.split("_", false, 1)[1]
static func user_id_from_filename(user_filename: String) -> int:
	var no_extension = user_filename.get_file().get_basename()
	return int(no_extension.split("_", false, 1)[0])
