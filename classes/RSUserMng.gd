extends Node
class_name RSUserMng

static var _log: TwitchLogger = TwitchLogger.new(&"RSUserMng")

var folder: String:
	get: return RSSettings.get_users_path()
var known: Dictionary[int, RSUser] = {}
var unknown: Dictionary[int, RSUser] = {}
var username_to_user_id: Dictionary[String, int] = {}
var live_streamers_data: Dictionary[int, TwitchStream] = {}
var tmr_refresh_live: Timer
var _started := false
var _refreshing_live := false
var _profiles_loaded: Dictionary[int, bool] = {}
var _pending_lookups: Dictionary[String, bool] = {}

signal user_added(user: RSUser)
signal user_updated(user: RSUser)
signal user_deleted(user: RSUser)
signal known_users_updated
signal live_streamers_updating
signal live_streamers_updated
signal profile_lookup_finished(key: String)

func start() -> void:
	if _started:
		return
	_started = true
	known = load_all_users_from_folder(folder)
	for user: RSUser in known.values():
		unknown.erase(user.user_id)
		_index_user(user)
	connect_signals()
	known_users_updated.emit()

func connect_signals() -> void:
	if not RS.twitcher.connected_to_twitch.is_connected(_on_twitch_connected):
		RS.twitcher.connected_to_twitch.connect(_on_twitch_connected)
	if not RS.twitcher.first_session_message.is_connected(_on_first_session_message):
		RS.twitcher.first_session_message.connect(_on_first_session_message)

static func normalize_username(username: String) -> String:
	return username.strip_edges().trim_prefix("@").to_lower()

func _index_user(user: RSUser) -> void:
	for alias in username_to_user_id.keys():
		if username_to_user_id[alias] == user.user_id:
			username_to_user_id.erase(alias)
	user.username = normalize_username(user.username)
	if not user.username.is_empty():
		username_to_user_id[user.username] = user.user_id

func get_cached_user(user_id: int) -> RSUser:
	return known.get(user_id, unknown.get(user_id))

## Record identity immediately, without requiring an API call or adding a known user.
func observe_user(user_id: int, username: String = "", display_name: String = "", color: String = "") -> RSUser:
	if user_id <= 0:
		return null
	var user := get_cached_user(user_id)
	if user == null:
		user = RSUser.new()
		user.user_id = user_id
		user.added_on = Time.get_unix_time_from_system()
		user.twitch_chat_color = Color.WHITE
		unknown[user_id] = user
	if not username.is_empty():
		user.username = normalize_username(username)
	if not display_name.is_empty():
		user.display_name = display_name
	elif user.display_name.is_empty():
		user.display_name = user.username if not user.username.is_empty() else "User %d" % user_id
	if color.is_valid_html_color():
		user.twitch_chat_color = Color(color)
	_index_user(user)
	return user

func save_user(user: RSUser) -> bool:
	if user == null or not save_user_to_json(user, folder):
		return false
	var is_new := not known.has(user.user_id)
	known[user.user_id] = user
	unknown.erase(user.user_id)
	_index_user(user)
	if is_new:
		user_added.emit(user)
	else:
		user_updated.emit(user)
	known_users_updated.emit()
	return true

func save_all() -> void:
	save_all_users_to_folder(known, folder)

func delete_user(user: RSUser) -> void:
	if user == null:
		return
	for filename in _user_files(user.user_id, folder):
		if OS.move_to_trash(folder.path_join(filename)) != OK:
			_log.e("Could not delete user file: %s" % filename)
			return
	known.erase(user.user_id)
	# Retain the observed identity for this session, without retaining membership.
	unknown[user.user_id] = user
	_index_user(user)
	live_streamers_data.erase(user.user_id)
	user_deleted.emit(user)
	known_users_updated.emit()

func create_refresh_live_stream_timer() -> void:
	if tmr_refresh_live == null:
		tmr_refresh_live = Timer.new()
		tmr_refresh_live.wait_time = 240
		tmr_refresh_live.timeout.connect(_on_tmr_refresh_live_timeout)
		add_child(tmr_refresh_live)
	tmr_refresh_live.start()

func refresh_live_streamers() -> void:
	if _refreshing_live or not RS.twitcher.is_connected_to_twitch:
		return
	_refreshing_live = true
	live_streamers_updating.emit()
	live_streamers_data = await RS.twitcher.get_live_streamers_data()
	_refreshing_live = false
	live_streamers_updated.emit()

func get_known_user_from_user_id(user_id: int) -> RSUser:
	return known.get(user_id)

func get_known_user_from_username(username: String) -> RSUser:
	return known.get(username_to_user_id.get(normalize_username(username), 0))

func get_any_user_from_username(username: String) -> RSUser:
	username = normalize_username(username)
	if username.is_empty():
		return null
	if username_to_user_id.has(username):
		return await get_any_user_from_user_id(username_to_user_id[username])
	return await user_from_twitch_api(username)

func get_any_user_from_user_id(user_id: int) -> RSUser:
	if user_id <= 0:
		return null
	var user := get_cached_user(user_id)
	if known.has(user_id) or _profiles_loaded.has(user_id):
		return user
	var fetched := await user_from_twitch_api("", user_id)
	return fetched if fetched != null else user

func get_t_user_from_twitch_api(user_id: int) -> TwitchUser:
	return await RS.twitcher.get_user_by_id(str(user_id))

func user_from_twitch_api(username: String = "", user_id: int = 0) -> RSUser:
	username = normalize_username(username)
	if user_id <= 0 and username.is_empty():
		return null
	var key := str(user_id) if user_id > 0 else username
	if _pending_lookups.has(key):
		while _pending_lookups.has(key):
			await profile_lookup_finished
		return get_cached_user(user_id if user_id > 0 else username_to_user_id.get(username, 0))
	_pending_lookups[key] = true
	var t_user: TwitchUser
	if user_id > 0:
		t_user = await RS.twitcher.get_user_by_id(str(user_id))
	else:
		t_user = await RS.twitcher.get_user(username)
	var user: RSUser
	if t_user != null and int(t_user.id) > 0:
		var color: Color = await RS.twitcher.get_user_color(int(t_user.id))
		# Reuse the existing object even if another lookup completed while awaiting.
		user = observe_user(int(t_user.id), t_user.login, t_user.display_name)
		user.update_from_twitch_user(t_user)
		if color.a > 0:
			user.twitch_chat_color = color
		_index_user(user)
		_profiles_loaded[user.user_id] = true
	_pending_lookups.erase(key)
	profile_lookup_finished.emit(key)
	return user

func get_known_streamers() -> Dictionary[int, RSUser]:
	var result: Dictionary[int, RSUser] = {}
	for user_id: int in known:
		if known[user_id].is_streamer:
			result[user_id] = known[user_id]
	return result

func is_user_known(user: RSUser) -> bool:
	return user != null and known.has(user.user_id)

func is_username_known(username: String) -> bool:
	return get_known_user_from_username(username) != null

func is_user_id_known(user_id: int) -> bool:
	return known.has(user_id)

func update_known_user_from_twitch(user: RSUser) -> void:
	if not is_user_known(user):
		return
	var refreshed := await user_from_twitch_api("", user.user_id)
	# A user can be removed while the lookup is pending.
	if refreshed != null and known.has(user.user_id):
		save_user(refreshed)

func _on_first_session_message(message: TwitchChatMessage) -> void:
	var user := observe_user(int(message.chatter_user_id), message.chatter_user_login, message.chatter_user_name, message.color)
	if is_user_known(user):
		save_user(user)
		await update_known_user_from_twitch(user)

func _on_twitch_connected() -> void:
	create_refresh_live_stream_timer()
	refresh_live_streamers()

func _on_tmr_refresh_live_timeout() -> void:
	refresh_live_streamers()

func _on_user_request_add(_from_username: String = "", info: TwitchCommandInfo = null, _args: PackedStringArray = []) -> void:
	if info == null or info.original_message == null:
		return
	var message: TwitchChatMessage = info.original_message
	var user := observe_user(int(message.chatter_user_id), message.chatter_user_login, message.chatter_user_name, message.color)
	if user == null:
		return
	if is_user_known(user):
		RS.twitcher.chat("You are in %s! You are already in..." % user.display_name)
		return
	if save_user(user):
		RS.twitcher.chat("Welcome in %s Ridiculous Streaming!" % user.display_name)
		await update_known_user_from_twitch(user)

static func load_all_users_from_folder(user_folder: String) -> Dictionary[int, RSUser]:
	var result: Dictionary[int, RSUser] = {}
	var timestamps: Dictionary[int, int] = {}
	var dir := DirAccess.open(user_folder)
	if dir == null:
		return result
	var files := dir.get_files()
	files.sort()
	for filename in files:
		if filename.get_extension() != "json":
			continue
		var path := user_folder.path_join(filename)
		var user := load_user_from_json(path)
		if user == null:
			continue
		var timestamp := FileAccess.get_modified_time(path)
		if result.has(user.user_id) and timestamp < timestamps[user.user_id]:
			continue
		result[user.user_id] = user
		timestamps[user.user_id] = timestamp
	return result

static func save_all_users_to_folder(users: Dictionary, user_folder: String) -> void:
	for user: RSUser in users.values():
		save_user_to_json(user, user_folder)

static func load_user_from_json(path: String) -> RSUser:
	var data: Variant = RSUtl.load_json(path)
	if not data is Dictionary or int(data.get("user_id", 0)) <= 0 or str(data.get("username", "")).is_empty():
		_log.w("Skipping invalid user file: %s" % path)
		return null
	return RSUser.from_json(data)

static func save_user_to_json(user: RSUser, user_folder: String) -> bool:
	if user == null or user.user_id <= 0:
		return false
	user.username = normalize_username(user.username)
	if user.username.is_empty() or not user.username.is_valid_filename():
		_log.e("Cannot save user with invalid username")
		return false
	var filename := user_filename_json_from_user(user)
	if not RSUtl.save_to_json(user_folder.path_join(filename), user.to_dict()):
		return false
	# Keep old files until the replacement is safely saved; remove only this ID's duplicates.
	for old_filename in _user_files(user.user_id, user_folder):
		if old_filename != filename:
			if OS.move_to_trash(user_folder.path_join(old_filename)) != OK:
				_log.w("Could not remove old user file: %s" % old_filename)
	return true

static func _user_files(user_id: int, user_folder: String) -> PackedStringArray:
	var result := PackedStringArray()
	var dir := DirAccess.open(user_folder)
	if dir == null:
		return result
	for filename in dir.get_files():
		if filename.get_extension() == "json" and user_id_from_filename(filename) == user_id:
			result.append(filename)
	return result

static func get_filename_from_user_id(user_id: int, user_folder: String = "") -> String:
	var files := _user_files(user_id, user_folder)
	return files[0] if not files.is_empty() else ""

static func user_filename_basename_from_user(user: RSUser) -> String:
	return "%d_%s" % [user.user_id, normalize_username(user.username)]

static func user_filename_json_from_user(user: RSUser) -> String:
	return user_filename_basename_from_user(user) + ".json"

static func username_from_filename(filename: String) -> String:
	var parts := filename.get_file().get_basename().split("_", true, 1)
	return parts[1] if parts.size() > 1 else ""

static func user_id_from_filename(filename: String) -> int:
	return int(filename.get_file().get_basename().get_slice("_", 0))
