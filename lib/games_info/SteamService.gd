@tool
@icon("steam_icon.png")
extends Node
class_name SteamService

#const STEAM_SERVICE_ISTORE_API_URL = "https://api.steampowered.com/IStoreService/"
#const ENDPOINT_ISTORE_GET_APP_INFO = "GetAppInfo/v1/?key={steamkey}&appid={appid}&include_games=true"
const STEAM_SERVICE_STORE_API_URL = "https://store.steampowered.com/api/"
const ENDPOINT_STORE_GET_APP_INFO = "appdetails?appids={appid}"

static var _log: TwitchLogger = TwitchLogger.new(&"SteamService")


func _ready() -> void:
	pass


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
		_log.e("Error: %s" % error_string(_err))
		return
	
	var http_result: Array = await http_request.request_completed
	var result: int = http_result[0]
	var response_code: int = http_result[1]
	var _headers: PackedStringArray = http_result[2]
	var body: PackedByteArray = http_result[3]
	_log.d("result: " + str(result) )
	_log.d("response_code: " + str(response_code) )
	if response_code != HTTPClient.RESPONSE_OK:
		_log.e("Request failed. Response code %s" % response_code)
		return
	var response_json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	if not response_json.has(str(app_id)):
		return null
	if not response_json[str(app_id)].has("data"):
		return null
	var game_data: Dictionary = response_json[str(app_id)]["data"]
	game_data["steam_app_id"] = game_data["steam_appid"]
	http_request.queue_free()
	return SteamAppData.from_json(game_data)
