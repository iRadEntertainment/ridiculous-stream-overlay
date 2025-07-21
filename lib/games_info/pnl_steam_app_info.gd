@tool
extends PanelContainer
class_name PnlSteamAppInfo


@export var enable_logger: bool = true
@warning_ignore("unused_private_class_variable")
@export_tool_button("Search", "Button") var _search = tool_search
@export var tool_app_id: int

#region Test Apps
enum SteamGames{
	BLOOD_AND_MEAD,
	RIDICULOUS_SHIPPING,
	MEMORI,
	BLOCK_SHOP,
	FIELD_OF_HEROES,
	ZOOIKA,
	KOOK,
	ALPINE_LAKE,
	REPLICAT,
	CARBRIX,
	KERKER,
	XXX_CRAZYMIKE_XXX,
	MAGNET_JACK,
	ROGUE_BLIGHT,
	RISE_OF_PIRACY,
	MEGABAT,
	WARLOCKS_GANTLET,
	ARTIFICIAL,
	OCEAN_MIRROR,
	SPACE_SCAVANGER2,
	SCOPECREEP,
	THE_UNWANTED_WAR,
	HYPERONS,
	EPIC_HERO_GAME,
	CYBER_LOUNGE_TYCOON,
	OLD_BONES,
	GRIME_AND_GOLD,
	LONG_GONE,
	BOMB_AROUND,
	NO_SIGNAL,
	HEMOMANCER,
	SOPHIAS_PATH,
	WAKE_CUP,
	PROVIDENCE,
	TORSO_TENNIS,
	STICK_AND_STACK,
	FALINERE_FANTASY,
	MR_FARMBOY,
	ECHO_SHREDD,
}
const STEAM_APP_IDS: Dictionary[SteamGames, int] = {
	SteamGames.BLOOD_AND_MEAD: 1081830,
	SteamGames.RIDICULOUS_SHIPPING: 2649940,
	SteamGames.MEMORI: 1712700,
	SteamGames.BLOCK_SHOP: 2731590,
	SteamGames.FIELD_OF_HEROES: 1267290,
	SteamGames.ZOOIKA: 2994730,
	SteamGames.KOOK: 2329690,
	SteamGames.ALPINE_LAKE: 2341620,
	SteamGames.REPLICAT: 3509430,
	SteamGames.CARBRIX: 3712430,
	SteamGames.KERKER: 2645100,
	SteamGames.XXX_CRAZYMIKE_XXX: 2468680,
	SteamGames.MAGNET_JACK: 1491800,
	SteamGames.ROGUE_BLIGHT: 1890310,
	SteamGames.RISE_OF_PIRACY: 1400660,
	SteamGames.MEGABAT: 2429230,
	SteamGames.WARLOCKS_GANTLET: 2391180,
	SteamGames.ARTIFICIAL: 904510,
	SteamGames.OCEAN_MIRROR: 2725640,
	SteamGames.SPACE_SCAVANGER2: 1962010,
	SteamGames.SCOPECREEP: 3595710,
	SteamGames.THE_UNWANTED_WAR: 2487370,
	SteamGames.HYPERONS: 2479500,
	SteamGames.EPIC_HERO_GAME: 2081720,
	SteamGames.CYBER_LOUNGE_TYCOON: 1852150,
	SteamGames.OLD_BONES: 3358260,
	SteamGames.GRIME_AND_GOLD: 3165090,
	SteamGames.LONG_GONE: 1977610,
	SteamGames.BOMB_AROUND: 3539690,
	SteamGames.NO_SIGNAL: 2840590,
	SteamGames.HEMOMANCER: 3690780,
	SteamGames.SOPHIAS_PATH: 3197650,
	SteamGames.WAKE_CUP: 2881430,
	SteamGames.PROVIDENCE: 3643600,
	SteamGames.TORSO_TENNIS: 2824780,
	SteamGames.STICK_AND_STACK: 3655080,
	SteamGames.FALINERE_FANTASY: 1976930,
	SteamGames.MR_FARMBOY: 2795090,
	SteamGames.ECHO_SHREDD: 3232000,
}

@export() var selected_steam_game: SteamGames:
	set(val):
		selected_steam_game = val
		if is_node_ready(): get_app_info(STEAM_APP_IDS[selected_steam_game])
@export() var test_data: SteamAppData
#endregion


var l: TwitchLogger = TwitchLogger.new("PnlSteamAppInfo")
var data: SteamAppData:
	set(val):
		data = val
		if is_node_ready():
			%btn_visit_page.disabled = data == null


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	l.color = Color.LIGHT_GREEN.to_html()
	l.enabled = enable_logger
	clear()


func tool_search() -> void:
	if !Engine.is_editor_hint():
		return
	if tool_app_id:
		get_app_info(tool_app_id)


func get_app_info(app_id: int) -> SteamAppData:
	var _data: SteamAppData = await %SteamService.get_steam_app_data(app_id)
	if not _data:
		return
	
	display_app_info(_data)
	if Engine.is_editor_hint():
		test_data = _data
	return _data


func display_app_info(_data: SteamAppData) -> void:
	data = _data
	%ln_search.text = str(data.steam_app_id)
	%lb_name.text = data.name
	%lb_author.text = "[i]by [b]%s[/b][/i]" % data.developers.front()
	%tex_capsule_img.texture = await load_texture_from_url(data.header_image)
	if !data.screenshots_thumbs.is_empty():
		%bg_img.texture = await load_texture_from_url(data.screenshots_thumbs.front())
	%lb_release_date.text = "[b]%s[/b]" % data.release_date.date
	# price
	%lb_price_descr.visible = !data.is_free
	%hb_price.visible = data.price_final_formatted != "" or data.is_free
	if %hb_price.visible:
		if data.is_free:
			%lb_price.text = "[b]Free to play![/b]"
		else:
			%lb_price.text = "[b]%s[/b]" % data.price_final_formatted
			if data.price_discount_percent != 0:
				%lb_price.text += " [b][i](%d%% discount!)[/i][/b]" % data.price_discount_percent
		
		if data.is_free or data.price_discount_percent != 0:
			%lb_price.text = "[color=green][wave]%s[/wave][/color]" % [%lb_price.text]
	
	%lb_short_description.text = data.short_description


func clear() -> void:
	data = null
	%ln_search.text = ""
	%lb_name.text = ""
	%lb_author.text = ""
	%tex_capsule_img.texture = null
	%bg_img.texture = null
	%lb_release_date.text = ""
	%lb_price.text = ""
	%hb_price.hide()
	%lb_short_description.text = ""


#region Utils
func load_texture_from_url(url: String) -> ImageTexture:
	var http_request: HTTPRequest = HTTPRequest.new()
	add_child(http_request)
	var url_no_query: String = url.split("?")[0]
	var file_type = url_no_query.get_extension()
	if not file_type in ["png", "jpeg", "jpg", "bmp", "webp", "svg"]:
		file_type = "webp"
	#if not file_type in ["png", "jpeg", "jpg", "bmp", "webp", "svg"]:
		#print("Wrong filetype %s" % file_type)
		#return
	
	var _err = http_request.request(url)
	if _err != OK:
		print("_err != OK")
		#l.e("Error request: %s" % error_string(_err))
		return
	
	var http_result: Array = await http_request.request_completed
	var _result: int = http_result[0]
	var response_code: int = http_result[1]
	var _headers: PackedStringArray = http_result[2]
	var image_buffer: PackedByteArray = http_result[3]
	if response_code != HTTPClient.RESPONSE_OK:
		print("response_code != HTTPClient.RESPONSE_OK")
		return
	
	var tex_image := Image.new()
	match file_type:
		"png": tex_image.load_png_from_buffer(image_buffer)
		"jpeg", "jpg": tex_image.load_jpg_from_buffer(image_buffer)
		"bmp": tex_image.load_bmp_from_buffer(image_buffer)
		"webp": tex_image.load_webp_from_buffer(image_buffer)
		"svg": tex_image.load_svg_from_buffer(image_buffer)
		_:
			l.e("%s format not recognised."%file_type)
			return
	
	var tex = ImageTexture.create_from_image(tex_image)
	http_request.queue_free()
	return tex
#endregion


#region Editor Signals
func _on_btn_close_pnl_pressed() -> void:
	hide()
func _on_btn_visit_page_pressed() -> void:
	if data:
		OS.shell_open(data.short_url)
#endregion
