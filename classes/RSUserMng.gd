extends Node
class_name RSUserMng

static var _log: TwitchLogger = TwitchLogger.new(&"RSUserMng")

## FILENAMES json
## file tamplate -> {user_id}_{username}.json

var folder: String:
	get(): return RSSettings.get_users_path()

var known: Dictionary[int, RSUser] = {} # {user_id (int): user_object (RSUser)}
# TODO: populate unknown users
var unknown: Dictionary[int, RSUser] = {} # {user_id (int): user_object (RSUser)} CACHE
var username_to_user_id: Dictionary[String, int] = {} # -> {username (String): user_id (int)} # used for known and cached unknown
var live_streamers_data: Dictionary[int, TwitchStream] = {} #user-ids
var tmr_refresh_live: Timer

signal user_added(user: RSUser)
signal user_updated(user: RSUser)
signal user_deleted(user: RSUser)
signal known_users_updated
signal live_streamers_updating
signal live_streamers_updated


#region INIT
func start():
	_log.i("Started")
	known = load_all_users_from_folder(folder)
	username_to_user_id = {}
	for user_id: int in known:
		var user: RSUser = known[user_id]
		username_to_user_id[user.username] = user_id
	known_users_updated.emit()


func connect_signals() -> void:
	RS.twitcher.connected_to_twitch.connect(_on_twitch_connected)
	RS.twitcher.first_session_message.connect(_on_first_session_message)
#endregion


#region LOAD/SAVE/DELETE
func save_user(user: RSUser) -> void:
	if not user:
		_log.e("RSUserMng: Trying to save user null")
		return
	save_user_to_json(user, folder)
	
	var user_is_new: bool = not is_user_id_known(user.user_id)
	known[user.user_id] = user
	username_to_user_id[user.username] = user.user_id
	if user_is_new: user_added.emit(user)
	else: user_updated.emit(user)
	known_users_updated.emit()


func save_all() -> void:
	_log.i("Saving all users")
	save_all_users_to_folder(known, folder)


func delete_user(user: RSUser) -> void:
	if not user:
		push_warning("RSUserMng: attempt to delete null User")
		return
	var filename: String = get_filename_from_user_id(user.user_id, folder)
	while not filename.is_empty():
		OS.move_to_trash(folder + filename)
		filename = get_filename_from_user_id(user.user_id, folder)
	
	if known.has(user.user_id):
		known.erase(user.user_id)
	if username_to_user_id.has(user.username):
		username_to_user_id.erase(user.username)
	user_deleted.emit(user)
	known_users_updated.emit()
#endregion


#region TWITCH
func create_refresh_live_stream_timer() -> void:
	tmr_refresh_live = Timer.new()
	tmr_refresh_live.wait_time = 240
	tmr_refresh_live.one_shot = false
	tmr_refresh_live.timeout.connect(_on_tmr_refresh_live_timeout)
	add_child(tmr_refresh_live)
	tmr_refresh_live.start()


func refresh_live_streamers() -> void:
	live_streamers_updating.emit()
	live_streamers_data = await RS.twitcher.get_live_streamers_data()
	live_streamers_updated.emit()
#endregion


#region USER UTILITIES
func get_known_user_from_user_id(user_id: int) -> RSUser:
	if !is_user_id_known(user_id):
		return
	return known[user_id]


func get_known_user_from_username(username: String) -> RSUser:
	if !is_username_known(username):
		return
	var user_id = username_to_user_id[username]
	return known[user_id]


func get_user_from_username(username: String) -> RSUser:
	var user: RSUser
	var user_id: int = 0
	if username in username_to_user_id.keys():
		user_id = username_to_user_id[username]
		user = await get_user_from_user_id(user_id)
	else:
		user = await user_from_twitch_api(username)
	return user
	

func get_user_from_user_id(user_id: int) -> RSUser:
	var user: RSUser
	if known.has(user_id):
		user = known[user_id]
	elif unknown.has(user_id):
		user = unknown[user_id]
	else:
		user = await user_from_twitch_api("", user_id)
	return user


func get_t_user_from_twitch_api(user_id: int) -> TwitchUser:
	var t_user: TwitchUser = await RS.twitcher.get_user_by_id(str(user_id))
	return t_user


func user_from_twitch_api(username: String = "", user_id: int = 0) -> RSUser:
	var t_user: TwitchUser
	if !username.is_empty():
		t_user = await RS.twitcher.get_user(username)
	elif user_id != 0:
		t_user = await RS.twitcher.get_user_by_id(str(user_id))
	if not t_user:
		return null
	
	var user := RSUser.new()
	user = RSUser.from_twitcher_user(t_user)
	user.twitch_chat_color = await RS.twitcher.get_user_color(int(t_user.id))
	# TODO: check if we want to update the known user dictionary here.
	# Probably move to: _on_chat()
	# if known.has(user.user_id):
	# 	known[user.user_id] = user
	# else:
	# 	unknown[user.user_id] = user
	return user


func get_known_streamers() -> Dictionary[int, RSUser]:
	var results: Dictionary[int, RSUser] = {}
	for user_id: int in known.keys():
		if known[user_id].is_streamer:
			results[user_id] = known[user_id]
	return results


func is_user_known(user: RSUser) -> bool:
	return known.has(user.user_id)


func is_username_known(username: String) -> bool:
	if username_to_user_id.has(username):
		var user_id = username_to_user_id[username]
		return is_user_id_known(user_id)
	return false


func is_user_id_known(user_id: int) -> bool:
	return known.has(user_id)


func update_known_user_from_twitch(user: RSUser) -> void:
	if !is_user_known(user):
		return
	
	var user_compare_from_twitch: RSUser = await user_from_twitch_api("", user.user_id)
	var user_has_edits := false
	
	# check username mismatch
	if user.username != user_compare_from_twitch.username:
		user.username = user_compare_from_twitch.username
		user_has_edits = true
	
	# check preferred twitch color
	if user.twitch_chat_color != user_compare_from_twitch.twitch_chat_color:
		user.twitch_chat_color = user_compare_from_twitch.twitch_chat_color
		user_has_edits = true
	
	# check changed profile picture
	if user.profile_image_url != user_compare_from_twitch.profile_image_url:
		user.profile_image_url = user_compare_from_twitch.profile_image_url
		user_has_edits = true

	# save user if edits occur
	if user_has_edits:
		save_user_to_json(user, folder)
		user_updated.emit(user)

#endregion


#region CONNECTED METHODS
func _on_first_session_message(_username: String, _message: String, tags: TwitchTags.PrivMsg) -> void:
	var user_id: int = int(tags.user_id)
	if is_user_id_known(user_id):
		var user: RSUser = await get_user_from_user_id(user_id)
		await update_known_user_from_twitch(user)


func _on_twitch_connected() -> void:
	create_refresh_live_stream_timer()
	refresh_live_streamers()


func _on_tmr_refresh_live_timeout() -> void:
	refresh_live_streamers()


# connected from commands in RSCustom
func _on_user_request_add(
			_from_username: String = "",
			info: TwitchCommandInfo = null,
			_args: PackedStringArray = []
		) -> void:
	var user_id: int = int(info.tags.user_id)
	var user: RSUser
	if is_user_id_known(user_id):
		user = get_known_user_from_user_id(user_id)
		RS.twitcher.chat("You are in %s! You are already in..." % user.display_name)
		return
	elif unknown.has(user_id):
		user = unknown[user_id]
	else:
		user = await get_user_from_user_id(user_id)
	if not user:
		_log.e("Adding user %s with user_id %d error. User not found" % [info.username, user_id])
		return
	RS.twitcher.chat("Welcome in %s Ridiculous Streaming!" % user.display_name)
	save_user(user)
#endregion


#region STATIC METHODS
static func load_all_users_from_folder(user_folder: String) -> Dictionary[int, RSUser]:
	var dic: Dictionary[int, RSUser] = {}
	var user_files = RSUtl.list_file_in_folder(user_folder, ["json"])
	for user_file in user_files:
		var abs_path = user_folder + user_file
		var user_dic: Dictionary = RSUtl.load_json(abs_path)
		var user: RSUser = RSUser.from_json(user_dic)
		dic[user.user_id] = user
	return dic


static func save_all_users_to_folder(users_dic: Dictionary, user_folder: String) -> void:
	for user: RSUser in users_dic.values():
		save_user_to_json(user, user_folder)

static func load_user_from_json(path: String) -> RSUser:
	if !FileAccess.file_exists(path):
		_log.e("Cannot find file: %s" % path)
		return null
	var user_dic: Dictionary = RSUtl.load_json(path)
	var user := RSUser.from_json(user_dic)
	return user
static func save_user_to_json(user: RSUser, user_folder: String) -> void:
	if user.username == "":
		_log.e("Save user to json: cannot save an user without a username")
		return
	var abs_path = user_folder + user_filename_json_from_user(user)
	var dict = user.to_dict()
	if not dict.is_empty():
		RSUtl.save_to_json(abs_path, dict)
	else:
		_log.e("Failed to save user. Missing data.")
static func get_filename_from_user_id(user_id: int, user_folder: String = "") -> String:
	var dir := DirAccess.open(user_folder)
	for filename in dir.get_files():
		var file_user_id: int = user_id_from_filename(filename)
		if file_user_id == user_id:
			return filename
	return ""


# static func load_user_from_file_by_username(username: String, user_folder: String) -> RSUser:
# 	var path := get_user_filepath(username, user_folder)
# 	if user.username == "":
# 		user.username = username_from_userfile(path)
# 		l.e("%s doesn't contain a username." % path.get_file())
# 	return user

static func user_filename_basename_from_user(user: RSUser) -> String:
	var dic: Dictionary = {"user_id": user.user_id, "username": user.username}
	return "{user_id}_{username}".format(dic)
static func user_filename_json_from_user(user: RSUser) -> String:
	return user_filename_basename_from_user(user) + ".json"
# static func user_filename_tres_from_user(user: RSUser) -> String:
# 	return user_filename_basename_from_user(user) + ".tres"
static func username_from_filename(user_filename: String) -> String:
	var no_extension = user_filename.get_file().get_basename()
	return no_extension.split("_", false, 1)[1]
static func user_id_from_filename(user_filename: String) -> int:
	var no_extension = user_filename.get_file().get_basename()
	return int(no_extension.split("_", false, 1)[0])
#endregion
