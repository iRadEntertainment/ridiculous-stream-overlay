@tool
@icon("steam_icon.png")
extends Node
class_name SteamService

#const STEAM_SERVICE_ISTORE_API_URL = "https://api.steampowered.com/IStoreService/"
#const ENDPOINT_ISTORE_GET_APP_INFO = "GetAppInfo/v1/?key={steamkey}&appid={appid}&include_games=true"
const STEAM_SERVICE_STORE_API_URL = "https://store.steampowered.com/api/"
const ENDPOINT_STORE_GET_APP_INFO = "appdetails?appids={appid}"

@onready var l: TwitchLogger = TwitchLogger.new("SteamService")


func _ready() -> void:
	l.color = Color.CORNFLOWER_BLUE.to_html()
	l.enabled = true
	l.debug = false


func get_steam_app_data(app_id: int) -> SteamAppData:
	var http_request = HTTPRequest.new()
	add_child(http_request)
	
	var store_request_query: Dictionary = {
		"appid": app_id,
	}
	var request_url: String = STEAM_SERVICE_STORE_API_URL + ENDPOINT_STORE_GET_APP_INFO
	request_url = request_url.format(store_request_query)
	var _err = http_request.request(request_url)
	if _err != OK:
		l.e("Error: %s" % error_string(_err))
		return
	
	var http_result: Array = await http_request.request_completed
	var result: int = http_result[0]
	var response_code: int = http_result[1]
	var _headers: PackedStringArray = http_result[2]
	var body: PackedByteArray = http_result[3]
	l.d("result: " + str(result) )
	l.d("response_code: " + str(response_code) )
	if response_code != HTTPClient.RESPONSE_OK:
		l.e("Request failed. Response code %s" % response_code)
		return
	var response_json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	if not response_json.has(str(app_id)):
		return null
	if not response_json[str(app_id)].has("data"):
		return null
	var game_data = response_json[str(app_id)]["data"]
	http_request.queue_free()
	return SteamAppData.from_json(game_data)
