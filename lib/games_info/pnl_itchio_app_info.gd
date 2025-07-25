@tool
extends PanelContainer
class_name PnlItchIOAppInfo


@export var enable_logger: bool = true
@warning_ignore("unused_private_class_variable")
@export_tool_button("Search", "Button") var _search = tool_search
@export var tool_app_url: String

#region Test Apps
enum ItchIOGames{
	RIDICULOUS_SHOPPING,
	THE_MAZE_AND_THE_BEAST,
	THE_SUNNYSIDE_MOTEL_IN_HUTTSVILLE_ARKANSAS,
	VOID_DRIVE_THROUGH,
	POTION_QUEST,
	SUPER_ROLL_OUT,
	COVINOS_ROTTEN_FRUIT,
	AUTENTIC_ITALIAN_PIZZA,
}
const ITCHIO_APP_URLS: Dictionary[ItchIOGames, String] = {
	ItchIOGames.RIDICULOUS_SHOPPING: "https://uff.itch.io/ridiculous-shopping",
	ItchIOGames.THE_MAZE_AND_THE_BEAST: "https://uff.itch.io/the-maze-and-the-beast",
	ItchIOGames.THE_SUNNYSIDE_MOTEL_IN_HUTTSVILLE_ARKANSAS: "https://fgaha56.itch.io/the-sunnyside-motel-in-huttsville-arkansas",
	ItchIOGames.VOID_DRIVE_THROUGH: "https://fgaha56.itch.io/void-drive-through",
	ItchIOGames.POTION_QUEST: "https://vex667.itch.io/potion-quest",
	ItchIOGames.SUPER_ROLL_OUT: "https://seano4d.itch.io/super-roll-out",
	ItchIOGames.COVINOS_ROTTEN_FRUIT: "https://jerem-watts.itch.io/gorley-cleans-up-covinos-rotten-fruit",
	ItchIOGames.AUTENTIC_ITALIAN_PIZZA: "https://trevron.itch.io/authentic-italian-pizza",
}

@export() var selected_itchio_game: ItchIOGames:
	set(val):
		selected_itchio_game = val
		if is_node_ready(): get_app_info(ITCHIO_APP_URLS[selected_itchio_game])
@export() var test_data: ItchIOAppData
#endregion

const IMG_VALID_FORMATS = ["png", "jpeg", "jpg", "bmp", "webp", "svg"]

static var _log: TwitchLogger = TwitchLogger.new(&"PnlSteamAppInfo")
var data: ItchIOAppData:
	set(val):
		data = val
		if is_node_ready():
			%btn_visit_page.disabled = data == null


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	clear()


func tool_search() -> void:
	if !Engine.is_editor_hint():
		return
	if tool_app_url:
		get_app_info(tool_app_url)


func get_app_info(app_url: String) -> ItchIOAppData:
	var _data: ItchIOAppData = await %ItchIOService.get_itch_app_data(app_url)
	if not _data:
		return
	
	display_app_info(_data)
	if Engine.is_editor_hint():
		test_data = _data
	return _data


func display_app_info(_data: ItchIOAppData) -> void:
	clear()
	data = _data
	%ln_search.text = str(data.url)
	%ln_app_id.text = str(data.id)
	%lb_name.text = data.title
	
	var authors_string: String = ""
	for i: int in data.authors.size():
		var author_dic: Dictionary = data.authors[i]
		authors_string += "[b][url={url}]{name}[/url][/b]".format(author_dic)
		if i+1 < data.authors.size():
			authors_string += ", "
	
	%lb_authors.text = "[i]by %s[/i]" % authors_string
	if data.cover_image:
		if data.cover_image.get_extension() in IMG_VALID_FORMATS:
			%tex_capsule_img.texture = await load_texture_from_url(data.cover_image)
	if not data.screenshots_thumbnails.is_empty():
		if data.screenshots_thumbnails.front().get_extension() in IMG_VALID_FORMATS:
			var texture: Texture2D = await load_texture_from_url(data.screenshots_thumbnails.front())
			if texture:
				%bg_img.texture = texture
	
	%lb_price_descr.visible = !data.is_free
	if data.is_free:
		%lb_price.text = "[color=green][wave][b]Free to play![/b][/wave][/color]"
	else:
		%lb_price.text = "[color=green][b]%s[/b][/color]" % data.price
	
	%lb_short_description.text = data.description


func clear() -> void:
	data = null
	%ln_search.text = ""
	%ln_app_id.text = ""
	
	%lb_name.text = ""
	%lb_authors.text = ""
	%tex_capsule_img.texture = null
	%bg_img.texture = null
	%lb_price.text = ""
	%lb_short_description.text = ""


#region Utils
func load_texture_from_url(url: String) -> ImageTexture:
	var http_request: HTTPRequest = HTTPRequest.new()
	add_child(http_request)
	var file_type = url.get_extension()
	if not file_type in IMG_VALID_FORMATS:
		return
	
	var _err = http_request.request(url)
	if _err != OK:
		#_log.e("Error request: %s" % error_string(_err))
		return
	
	var http_result: Array = await http_request.request_completed
	var _result: int = http_result[0]
	var response_code: int = http_result[1]
	var _headers: PackedStringArray = http_result[2]
	var image_buffer: PackedByteArray = http_result[3]
	if response_code != HTTPClient.RESPONSE_OK:
		return
	
	var tex_image := Image.new()
	match file_type:
		"png": tex_image.load_png_from_buffer(image_buffer)
		"jpeg", "jpg": tex_image.load_jpg_from_buffer(image_buffer)
		"bmp": tex_image.load_bmp_from_buffer(image_buffer)
		"webp": tex_image.load_webp_from_buffer(image_buffer)
		"svg": tex_image.load_svg_from_buffer(image_buffer)
		_:
			_log.e("%s format not recognised."%file_type)
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


func _on_lb_authors_meta_clicked(meta: Variant) -> void:
	OS.shell_open(meta)
