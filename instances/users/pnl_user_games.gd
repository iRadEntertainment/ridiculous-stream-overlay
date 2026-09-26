extends PanelContainer
class_name PnlUserGames

@onready var pnl_steam_app_info: PnlSteamAppInfo = %pnl_steam_app_info
@onready var pnl_itchio_app_info: PnlItchIOAppInfo = %pnl_itchio_app_info


var _selection_revision := 0

var steam_app_ids: Dictionary[int, SteamAppData]:
	get():
		if user: return user.steam_app_ids
		return {}
var itchio_app_urls: Dictionary[String, ItchIOAppData]:
	get():
		if user: return user.itchio_app_urls
		return {}

signal game_info_steam_pressed(steam_data: SteamAppData)
signal game_info_itchio_pressed(itchio_data: ItchIOAppData)

var user: RSUser: set = set_user


func _ready() -> void:
	_toggle_btns(false)
	visibility_changed.connect(_queue_game_refresh)
	RS.user_mng.game_refresh.game_refresh_finished.connect(_on_auto_game_refresh_finished)


func _populate() -> void:
	for steam_app_id: int in steam_app_ids:
		var data: SteamAppData = steam_app_ids[steam_app_id]
		_show_steam_entry(steam_app_id, data)
	for itchio_app_url: String in itchio_app_urls:
		var data: ItchIOAppData = itchio_app_urls[itchio_app_url]
		_show_itchio_entry(itchio_app_url, data)


func _toggle_btns(val: bool) -> void:
	%ln_add_steam_app_id.editable = val
	%btn_steam_get_info.disabled = !val
	%btn_steam_add_game.disabled = !val
	%ln_add_itch_io_link.editable = val
	%btn_itchio_get_info.disabled = !val
	%btn_itchio_add_game.disabled = !val


func get_steam_app_ids() -> Array[int]:
	var results: Array[int] = []
	for entry: EntryGameList in %vb_steam_app_list.get_children():
		if not entry.steam_app_id in results:
			results.append(entry.steam_app_id)
	return results


func get_itchio_app_urls() -> Array[String]:
	var results: Array[String] = []
	for entry: EntryGameList in %vb_itch_app_list.get_children():
		if not entry.itchio_app_url in results:
			results.append(entry.itchio_app_url)
	return results


func set_user(_user: RSUser) -> void:
	user = _user
	_toggle_btns(user != null)
	clear()
	_populate()
	_queue_game_refresh()


func _queue_game_refresh() -> void:
	if is_node_ready() and is_visible_in_tree() and not is_queued_for_deletion():
		RS.user_mng.game_refresh.queue_user(user)


func _on_auto_game_refresh_finished(target: RSUser, kind: String, key: Variant, success: bool, message: String) -> void:
	if target != user:
		return
	if not success:
		_show_error(message)
		return
	# Refresh the entry without opening or switching the game details tab.
	if kind == "steam":
		var data: SteamAppData = target.steam_app_ids[key]
		_show_steam_entry(key, data)
		if pnl_steam_app_info.is_visible_in_tree() and pnl_steam_app_info.data != null and pnl_steam_app_info.data.steam_app_id == key:
			pnl_steam_app_info.display_app_info(data)
	else:
		var data: ItchIOAppData = target.itchio_app_urls[key]
		_show_itchio_entry(key, data)
		if pnl_itchio_app_info.is_visible_in_tree() and pnl_itchio_app_info.data != null and pnl_itchio_app_info.data.id == data.id:
			pnl_itchio_app_info.display_app_info(data)


func clear() -> void:
	_selection_revision += 1
	%games_error.hide()
	%tab_game_info.hide()
	for entry: EntryGameList in %vb_steam_app_list.get_children() + %vb_itch_app_list.get_children():
		entry.get_parent().remove_child(entry)
		entry.queue_free()


func check_steam_app(steam_app_id: int) -> void:
	var revision := _selection_revision
	var data := await _fetch_steam_app(steam_app_id)
	if revision != _selection_revision:
		return
	if data == null:
		_show_error("Could not retrieve Steam game info. Try again.")
		return
	_on_entry_game_info_pressed(data)


func _fetch_steam_app(app_id: int) -> SteamAppData:
	return await pnl_steam_app_info.get_node("%SteamService").get_steam_app_data(app_id)


func _fetch_itchio_app(url: String) -> ItchIOAppData:
	return await pnl_itchio_app_info.get_node("%ItchIOService").get_itch_app_data(url)


func _can_edit(target: RSUser, revision: int) -> bool:
	return is_inside_tree() and not is_queued_for_deletion() and revision == _selection_revision \
		and target != null and user == target and RS.user_mng.get_known_user_from_user_id(target.user_id) == target


func _show_error(message: String) -> void:
	%games_error.text = message
	%games_error.show()


## Keep memory and the entry unchanged when persistence fails.
func _save_game_change(games: Dictionary, key: Variant, data: Resource) -> bool:
	if not _can_edit(user, _selection_revision):
		_show_error("This user is no longer in the known list. Select the user again.")
		return false
	var previous: Resource = games.get(key)
	if data == null:
		games.erase(key)
	else:
		games[key] = data
	if not RS.user_mng.save_user(user):
		if previous == null:
			games.erase(key)
		else:
			games[key] = previous
		_show_error("Could not save the game change. The previous data was kept. Try again.")
		return false
	%games_error.hide()
	if data is SteamAppData:
		RS.user_mng.game_refresh.mark_refreshed(user, "steam", key)
	elif data is ItchIOAppData:
		RS.user_mng.game_refresh.mark_refreshed(user, "itch", key)
	return true


func add_steam_entry(
	steam_app_id: int,
	save_user: bool,
	_steam_app_data: SteamAppData = null
) -> bool:
	var target := user
	var revision := _selection_revision
	if target == null or steam_app_id <= 0:
		_show_error("Enter a valid Steam app ID or store URL.")
		return false
	var data := _steam_app_data
	if data == null:
		data = await _fetch_steam_app(steam_app_id)
	if not _can_edit(target, revision):
		return false
	if data == null or data.steam_app_id != steam_app_id:
		_show_error("Could not retrieve Steam game info. Try again.")
		return false
	if save_user and not _save_game_change(steam_app_ids, steam_app_id, data):
		return false
	_show_steam_entry(steam_app_id, data)
	return true


func _show_steam_entry(steam_app_id: int, data: SteamAppData) -> void:
	for entry: EntryGameList in %vb_steam_app_list.get_children():
		if entry.steam_app_id == steam_app_id:
			entry.steam_data = data
			entry.populate()
			return
	var new_entry: EntryGameList = preload("res://instances/entries/entry_game_list.tscn").instantiate()
	new_entry.type = EntryGameList.Type.STEAM
	new_entry.steam_app_id = steam_app_id
	new_entry.steam_data = data
	new_entry.game_info_steam_pressed.connect(_on_entry_game_info_pressed)
	new_entry.entry_deleted.connect(_on_entry_deleted)
	new_entry.game_data_refreshed.connect(_on_entry_game_data_refreshed.bind(user, _selection_revision))
	%vb_steam_app_list.add_child(new_entry)


func check_itchio_app(itchio_app_url: String) -> void:
	var revision := _selection_revision
	var data := await _fetch_itchio_app(itchio_app_url)
	if revision != _selection_revision:
		return
	if data == null:
		_show_error("Could not retrieve itch.io game info. Try again.")
		return
	_on_entry_game_info_pressed(data)


func add_itchio_entry(
	itchio_app_url: String,
	save_user: bool,
	_itchio_app_data: ItchIOAppData = null,
) -> bool:
	var target := user
	var revision := _selection_revision
	itchio_app_url = itchio_app_url.strip_edges().trim_suffix("/")
	if target == null or itchio_app_url.is_empty():
		return false
	var data := _itchio_app_data
	if data == null:
		data = await _fetch_itchio_app(itchio_app_url)
	if not _can_edit(target, revision):
		return false
	if data == null or data.url.is_empty():
		_show_error("Could not retrieve itch.io game info. Try again.")
		return false
	# Keep the existing association key when refreshing an entry; use the
	# API's canonical URL for new entries so trailing slashes do not duplicate it.
	var key := data.url.strip_edges().trim_suffix("/")
	for existing: String in itchio_app_urls:
		if existing.trim_suffix("/") == key:
			key = existing
			break
	if save_user and not _save_game_change(itchio_app_urls, key, data):
		return false
	_show_itchio_entry(key, data)
	return true


func _show_itchio_entry(itchio_app_url: String, data: ItchIOAppData) -> void:
	for entry: EntryGameList in %vb_itch_app_list.get_children():
		if entry.itchio_app_url == itchio_app_url:
			entry.itchio_data = data
			entry.populate()
			return
	var new_entry: EntryGameList = preload("res://instances/entries/entry_game_list.tscn").instantiate()
	new_entry.type = EntryGameList.Type.ITCHIO
	new_entry.itchio_app_url = itchio_app_url
	new_entry.itchio_data = data
	new_entry.game_info_itchio_pressed.connect(_on_entry_game_info_pressed)
	new_entry.entry_deleted.connect(_on_entry_deleted)
	new_entry.game_data_refreshed.connect(_on_entry_game_data_refreshed.bind(user, _selection_revision))
	%vb_itch_app_list.add_child(new_entry)


func delete_steam_entry(steam_app_id: int) -> void:
	if not user:
		push_warning("Panel Games: No user")
		return
	if steam_app_id in steam_app_ids:
		if not _save_game_change(steam_app_ids, steam_app_id, null):
			return
	for entry: EntryGameList in %vb_steam_app_list.get_children():
		if entry.is_queued_for_deletion(): continue
		if !entry.steam_app_id in steam_app_ids:
			entry.get_parent().remove_child(entry)
			entry.queue_free()


func delete_itchio_entry(itchio_app_url: String) -> void:
	if not user:
		push_warning("Panel Games: No user")
		return
	if itchio_app_url in itchio_app_urls:
		if not _save_game_change(itchio_app_urls, itchio_app_url, null):
			return
	for entry: EntryGameList in %vb_itch_app_list.get_children():
		if entry.is_queued_for_deletion(): continue
		if !entry.itchio_app_url in itchio_app_urls:
			entry.get_parent().remove_child(entry)
			entry.queue_free()


func _delete_entry(entry: EntryGameList) -> void:
	match entry.type:
		EntryGameList.Type.STEAM:
			delete_steam_entry(entry.steam_app_id)
		EntryGameList.Type.ITCHIO:
			delete_itchio_entry(entry.itchio_app_url)


#region Utilities
# Special thanks: Siekwie (https://www.twitch.tv/siekwie)
func is_link(text: String) -> bool:
	var url_regex = RegEx.new()
	# This pattern matches http, https, and www. links
	url_regex.compile(r"(https?://[^\s]+)|(www.[^\s]+)")
	return url_regex.search(text) != null


func extract_steam_app_id(url: String) -> int:
	var regex = RegEx.new()
	# This pattern captures the number after /app/
	regex.compile(r"store.steampowered.com/app/(\d+)")
	var result = regex.search(url)
	if result:
		return result.get_string(1).to_int() # Group 1 is the app ID
	return 0
#endregion


#region Entries signals
func _on_entry_game_info_pressed(_data: Variant) -> void:
	if _data == null:
		return
	%tab_game_info.show()
	if _data is SteamAppData:
		pnl_steam_app_info.display_app_info(_data)
		pnl_steam_app_info.show()
	elif _data is ItchIOAppData:
		pnl_itchio_app_info.display_app_info(_data)
		pnl_itchio_app_info.show()


func _on_entry_deleted(entry: EntryGameList) -> void:
	if not entry.is_inside_tree() or entry.is_queued_for_deletion():
		return
	_delete_entry(entry)


func _on_entry_game_data_refreshed(entry: EntryGameList, data: Resource, target: RSUser, revision: int) -> void:
	if not _can_edit(target, revision) or not entry.is_inside_tree() or entry.is_queued_for_deletion():
		return
	match entry.type:
		EntryGameList.Type.STEAM:
			if not steam_app_ids.has(entry.steam_app_id) or not data is SteamAppData or data.steam_app_id != entry.steam_app_id:
				return
			if not _save_game_change(steam_app_ids, entry.steam_app_id, data):
				return
			entry.steam_data = data
		EntryGameList.Type.ITCHIO:
			if not itchio_app_urls.has(entry.itchio_app_url) or not data is ItchIOAppData or data.url.is_empty():
				return
			if not _save_game_change(itchio_app_urls, entry.itchio_app_url, data):
				return
			entry.itchio_data = data
	entry.populate()
	_on_entry_game_info_pressed(data)
#endregion


#region Inspector signals
func _on_ln_add_steam_app_id_text_submitted(_new_text: String) -> void:
	_on_btn_steam_add_game_pressed()
func _on_btn_steam_get_info_pressed() -> void:
	var text: String = %ln_add_steam_app_id.text
	var app_id: int
	if text.is_empty():
		return
	if is_link(text):
		app_id = extract_steam_app_id(text)
	else:
		app_id = int(text)
	if app_id != 0:
		check_steam_app(app_id)
func _on_btn_steam_add_game_pressed() -> void:
	if %btn_steam_add_game.disabled or %ln_add_steam_app_id.text.is_empty():
		return
	var text: String = %ln_add_steam_app_id.text.strip_edges()
	var app_id := extract_steam_app_id(text) if is_link(text) else text.to_int()
	var revision := _selection_revision
	%btn_steam_add_game.disabled = true
	var saved := await add_steam_entry(app_id, true)
	if revision == _selection_revision:
		%btn_steam_add_game.disabled = false
		if saved and %ln_add_steam_app_id.text.strip_edges() == text:
			%ln_add_steam_app_id.text = ""


func _on_ln_add_itch_io_link_text_submitted(_new_text: String) -> void:
	_on_btn_itchio_add_game_pressed()
func _on_btn_itchio_get_info_pressed() -> void:
	if %ln_add_itch_io_link.text.is_empty():
		return
	check_itchio_app( %ln_add_itch_io_link.text )
func _on_btn_itchio_add_game_pressed() -> void:
	if %btn_itchio_add_game.disabled or %ln_add_itch_io_link.text.is_empty():
		return
	var text: String = %ln_add_itch_io_link.text
	var revision := _selection_revision
	%btn_itchio_add_game.disabled = true
	var saved := await add_itchio_entry(text, true)
	if revision == _selection_revision:
		%btn_itchio_add_game.disabled = false
		if saved and %ln_add_itch_io_link.text == text:
			%ln_add_itch_io_link.text = ""
#endregion
