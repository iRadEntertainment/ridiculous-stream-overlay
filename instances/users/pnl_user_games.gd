extends PanelContainer
class_name PnlUserGames

@onready var pnl_steam_app_info: PnlSteamAppInfo = %pnl_steam_app_info
@onready var pnl_itchio_app_info: PnlItchIOAppInfo = %pnl_itchio_app_info


var steam_data: SteamAppData
var itchio_data: ItchIOAppData

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


func _populate() -> void:
	for steam_app_id: int in steam_app_ids:
		var data: SteamAppData = steam_app_ids[steam_app_id]
		add_steam_entry(steam_app_id, false, data)
	for itchio_app_url: String in itchio_app_urls:
		var data: ItchIOAppData = itchio_app_urls[itchio_app_url]
		add_itchio_entry(itchio_app_url, false, data)


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


func clear() -> void:
	%tab_game_info.hide()
	for entry: EntryGameList in %vb_steam_app_list.get_children() + %vb_itch_app_list.get_children():
		entry.queue_free()


func check_steam_app(steam_app_id: int) -> void:
	steam_data = await pnl_steam_app_info.get_app_info(steam_app_id)
	if steam_data:
		pnl_steam_app_info.display_app_info(steam_data)
		pnl_steam_app_info.show()


func add_steam_entry(
	steam_app_id: int,
	save_user: bool,
	_steam_app_data: SteamAppData = null
) -> void:
	if not user:
		push_warning("Panel Games: No user")
		return
	
	if _steam_app_data:
		steam_data = _steam_app_data
	
	if !steam_data:
		await check_steam_app(steam_app_id)
	elif steam_data.steam_app_id != steam_app_id:
		await check_steam_app(steam_app_id)
	
	if !steam_data:
		push_error("Panel Games: Steam data invalid!")
		print("App ID: %s" % steam_app_id)
		return
	
	if save_user:
		steam_app_ids.merge({steam_app_id: steam_data}, true)
		RS.user_mng.save_user(user)
	
	if steam_app_id in get_steam_app_ids():
		return
	var new_entry: EntryGameList = preload("res://instances/entries/entry_game_list.tscn").instantiate()
	new_entry.type = EntryGameList.Type.STEAM
	new_entry.steam_app_id = steam_app_id
	new_entry.steam_data = steam_data
	new_entry.game_info_steam_pressed.connect(_on_entry_game_info_pressed)
	new_entry.entry_deleted.connect(_on_entry_deleted)
	%vb_steam_app_list.add_child(new_entry)


func check_itchio_app(itchio_app_url: String) -> void:
	itchio_data = await pnl_itchio_app_info.get_app_info(itchio_app_url)
	if itchio_data:
		pnl_itchio_app_info.display_app_info(itchio_data)
		pnl_itchio_app_info.show()


func add_itchio_entry(
	itchio_app_url: String,
	save_user: bool,
	_itchio_app_data: ItchIOAppData = null,
) -> void:
	
	if not user:
		push_warning("Panel Games: No user")
		return
	
	if _itchio_app_data:
		itchio_data = _itchio_app_data
	
	if !itchio_data:
		await check_itchio_app(itchio_app_url)
	elif itchio_data.url != itchio_app_url:
		await check_itchio_app(itchio_app_url)
	
	if !itchio_data:
		return
	
	itchio_app_urls.merge({itchio_app_url: itchio_data}, true)
	RS.user_mng.save_user(user)
	
	
	if itchio_app_url in get_itchio_app_urls():
		return
	var new_entry: EntryGameList = preload("res://instances/entries/entry_game_list.tscn").instantiate()
	new_entry.type = EntryGameList.Type.ITCHIO
	new_entry.itchio_app_url = itchio_app_url
	new_entry.itchio_data = itchio_data
	new_entry.game_info_itchio_pressed.connect(_on_entry_game_info_pressed)
	new_entry.entry_deleted.connect(_on_entry_deleted)
	%vb_itch_app_list.add_child(new_entry)


func delete_steam_entry(steam_app_id: int) -> void:
	if not user:
		push_warning("Panel Games: No user")
		return
	if steam_app_id in steam_app_ids:
		steam_app_ids.erase(steam_app_id)
		RS.user_mng.save_user(user)
	for entry: EntryGameList in %vb_steam_app_list.get_children():
		if entry.is_queued_for_deletion(): continue
		if !entry.steam_app_id in steam_app_ids:
			entry.queue_free()


func delete_itchio_entry(itchio_app_url: String) -> void:
	if not user:
		push_warning("Panel Games: No user")
		return
	if itchio_app_url in itchio_app_urls:
		itchio_app_urls.erase(itchio_app_url)
		RS.user_mng.save_user(user)
	for entry: EntryGameList in %vb_itch_app_list.get_children():
		if entry.is_queued_for_deletion(): continue
		if !entry.itchio_app_url in itchio_app_urls:
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
	%tab_game_info.show()
	if _data is SteamAppData:
		pnl_steam_app_info.display_app_info(_data)
		pnl_steam_app_info.show()
	elif _data is ItchIOAppData:
		pnl_itchio_app_info.display_app_info(_data)
		pnl_itchio_app_info.show()


func _on_entry_deleted(entry: EntryGameList) -> void:
	_delete_entry(entry)
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
	if %ln_add_steam_app_id.text.is_empty():
		return
	add_steam_entry( int(%ln_add_steam_app_id.text), true )
	%ln_add_steam_app_id.text = ""


func _on_ln_add_itch_io_link_text_submitted(_new_text: String) -> void:
	_on_btn_itchio_add_game_pressed()
func _on_btn_itchio_get_info_pressed() -> void:
	if %ln_add_itch_io_link.text.is_empty():
		return
	check_itchio_app( %ln_add_itch_io_link.text )
func _on_btn_itchio_add_game_pressed() -> void:
	if %ln_add_itch_io_link.text.is_empty():
		return
	add_itchio_entry( %ln_add_itch_io_link.text, true )
	%ln_add_itch_io_link.text = ""
#endregion
