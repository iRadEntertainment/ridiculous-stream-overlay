extends PanelContainer
class_name PnlUserGames


var pnl_steam_app_info: PnlSteamAppInfo
var pnl_itchio_app_info: PnlItchIOAppInfo

var steam_data: SteamAppData
var itchio_data: ItchIOAppData

signal game_info_steam_pressed(steam_data: SteamAppData)
signal game_info_itchio_pressed(itchio_data: ItchIOAppData)

var user: RSUser:
	set(val):
		user = val
		populate()


func _ready() -> void:
	clear()


func populate() -> void:
	if not user:
		return


func get_steam_appids() -> Array[int]:
	return []


func get_itchio_app_urls() -> Array[String]:
	return []


func clear() -> void:
	user = null
	for entry: EntryGameList in %vb_steam_app_list.get_children() + %vb_itch_app_list.get_children():
		entry.queue_free()


func check_steam_app(steam_appid: int) -> void:
	if not pnl_steam_app_info:
		push_error("pnl_steam_app_info is null")
		return
	steam_data = await pnl_steam_app_info.get_app_info(steam_appid)
	if steam_data:
		pnl_steam_app_info.display_app_info(steam_data)
		pnl_steam_app_info.show()


func add_steam_entry(steam_appid: int) -> void:
	if not pnl_steam_app_info:
		push_error("pnl_steam_app_info is null")
		return
	
	if !steam_data:
		await check_steam_app(steam_appid)
	elif steam_data.steam_appid != steam_appid:
		await check_steam_app(steam_appid)
	
	if !steam_data:
		return
	
	var new_entry: EntryGameList = preload("res://instances/entry_game_list.tscn").instantiate()
	new_entry.type = EntryGameList.Type.STEAM
	new_entry.steam_appid = steam_appid
	new_entry.steam_data = steam_data
	new_entry.game_info_steam_pressed.connect(
		func(_data):
		pnl_steam_app_info.display_app_info(_data)
		pnl_steam_app_info.show()
		)
	%vb_steam_app_list.add_child(new_entry)


func check_itchio_app(itchio_app_url: String) -> void:
	if not pnl_itchio_app_info:
		push_error("pnl_itchio_app_info is null")
		return
	itchio_data = await pnl_itchio_app_info.get_app_info(itchio_app_url)
	if itchio_data:
		pnl_itchio_app_info.display_app_info(itchio_data)
		pnl_itchio_app_info.show()


func add_itchio_entry(itchio_app_url: String) -> void:
	if not pnl_itchio_app_info:
		push_error("pnl_itchio_app_info is null")
		return
	
	if !itchio_data:
		await check_itchio_app(itchio_app_url)
	elif itchio_data.url != itchio_app_url:
		await check_itchio_app(itchio_app_url)
	
	if !itchio_data:
		return
	
	var new_entry: EntryGameList = preload("res://instances/entry_game_list.tscn").instantiate()
	new_entry.type = EntryGameList.Type.ITCHIO
	new_entry.itchio_app_url = itchio_app_url
	new_entry.itchio_data = itchio_data
	new_entry.game_info_itchio_pressed.connect(
		func(_data):
		pnl_itchio_app_info.display_app_info(_data)
		pnl_itchio_app_info.show()
	)
	%vb_itch_app_list.add_child(new_entry)


func _on_btn_steam_get_info_pressed() -> void:
	if %ln_add_steam_appid.text.is_empty():
		return
	check_steam_app( int(%ln_add_steam_appid.text) )
func _on_btn_steam_add_game_pressed() -> void:
	if %ln_add_steam_appid.text.is_empty():
		return
	add_steam_entry( int(%ln_add_steam_appid.text) )


func _on_btn_itchio_get_info_pressed() -> void:
	if %ln_add_itch_io_link.text.is_empty():
		return
	check_itchio_app( %ln_add_itch_io_link.text )
func _on_btn_itchio_add_game_pressed() -> void:
	if %ln_add_itch_io_link.text.is_empty():
		return
	add_itchio_entry( %ln_add_itch_io_link.text )
