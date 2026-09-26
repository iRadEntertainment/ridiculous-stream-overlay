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
	if app_id <= 0:
		_log.w("Cannot fetch Steam metadata: invalid app ID %d." % app_id)
		return null
	_log.i("Fetching Steam metadata: app=%d." % app_id)
	var http_request = HTTPRequest.new()
	http_request.timeout = 30.0
	add_child(http_request)
	
	var store_request_query: Dictionary = {
		"appid": app_id,
	}
	var request_url: String = STEAM_SERVICE_STORE_API_URL + ENDPOINT_STORE_GET_APP_INFO
	request_url = request_url.format(store_request_query)
	var _err = http_request.request(request_url)
	if _err != OK:
		_log.e("Could not start Steam request for app=%d: %s." % [app_id, error_string(_err)])
		http_request.queue_free()
		return null
	
	var http_result: Array = await http_request.request_completed
	http_request.queue_free()
	var result: int = http_result[0]
	var response_code: int = http_result[1]
	var _headers: PackedStringArray = http_result[2]
	var body: PackedByteArray = http_result[3]
	_log.d("Steam response: app=%d, transport result=%d, HTTP=%d." % [app_id, result, response_code])
	if result != HTTPRequest.RESULT_SUCCESS or response_code != HTTPClient.RESPONSE_OK:
		_log.e("Steam request failed: app=%d, transport result=%d, HTTP=%d." % [app_id, result, response_code])
		return null
	var response_json: Variant = JSON.parse_string(body.get_string_from_utf8())
	return _parse_app_details(response_json, app_id)


func _parse_app_details(response_json: Variant, app_id: int) -> SteamAppData:
	if not response_json is Dictionary:
		_log.e("Invalid Steam JSON response: app=%d, expected an object." % app_id)
		return null
	var record: Variant = response_json.get(str(app_id))
	var game_data: Dictionary = {}
	if _record_matches_app(record, app_id):
		game_data = record.data
	else:
		# Store responses can use an unrelated outer key. Match the identity in
		# the metadata, never assume the first record belongs to the requested app.
		var matched_key := ""
		for key in response_json:
			var candidate: Variant = response_json[key]
			if not _record_matches_app(candidate, app_id):
				continue
			if not game_data.is_empty():
				_log.w("Ambiguous Steam response: multiple records match app=%d. Keeping previous data." % app_id)
				return null
			game_data = candidate.data
			matched_key = str(key)
		if not game_data.is_empty():
			_log.w("Steam response key differs: requested app=%d, record key=%s. Using metadata with verified steam_appid=%d." % [app_id, matched_key, app_id])
	if game_data.is_empty():
		_log.w("Steam returned no successful metadata matching app=%d (response keys=%s)." % [app_id, str(response_json.keys())])
		return null
	game_data = game_data.duplicate()
	game_data["steam_app_id"] = app_id
	_log.i("Retrieved Steam metadata: app=%d." % app_id)
	return SteamAppData.from_json(game_data)


func _record_matches_app(record: Variant, app_id: int) -> bool:
	return record is Dictionary and record.get("success", false) == true \
		and record.get("data") is Dictionary and int(record.data.get("steam_appid", 0)) == app_id
