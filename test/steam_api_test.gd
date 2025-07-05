@tool
extends Node

const STEAM_SERVICE_ISTORE_API_URL = "https://api.steampowered.com/IStoreService/"
const STEAM_SERVICE_STORE_API_URL = "https://store.steampowered.com/api/"
const ENDPOINT_ISTORE_GET_APP_INFO = "GetAppInfo/v1/?key={steamkey}&appid={appid}&include_games=true"
const ENDPOINT_STORE_GET_APP_INFO = "appdetails?appids={appid}"
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
}
enum ItchIOGames{
	RIDICULOUS_SHOPPING,
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
}
const ITCHIO_APP_IDS: Dictionary[ItchIOGames, String] = {
	ItchIOGames.RIDICULOUS_SHOPPING: "https://uff.itch.io/ridiculous-shopping",
}

@onready var http_request: HTTPRequest = $HTTPRequest

@export() var selected_steam_game: SteamGames:
	set(val):
		selected_steam_game = val
		selected_steam_app_id = STEAM_APP_IDS[selected_steam_game]
		if is_node_ready(): fetch_steam_app_data()
@export() var selected_itchio_game: ItchIOGames:
	set(val):
		selected_itchio_game = val
		selected_itchio_app_url = ITCHIO_APP_IDS[selected_itchio_game]
		if is_node_ready(): fetch_itchio_app_data()

@export var steam_app_data: SteamAppData
@export var itchio_app_data: ItchIOAppData


var selected_steam_app_id: int
var selected_itchio_app_url: String
var api_steamkey: String = ""


func _ready() -> void:
	http_request.request_completed.connect(_on_request_completed)


func fetch_itchio_app_data() -> void:
	itchio_app_data = await $ItchService.get_itch_app_data(selected_itchio_app_url)


func fetch_steam_app_data() -> void:
	steam_app_data = await $SteamService.get_steam_app_data(selected_steam_app_id)
	#var file_steam_key = FileAccess.open("res://api_steam.key", FileAccess.READ)
	#api_steamkey = file_steam_key.get_as_text().strip_edges().uri_encode()
	#get_steam_game_description(selected_steam_app_id)


func get_steam_game_description(app_id: int) -> void:
	# build request
	var store_request_query: Dictionary = {
		"appid": app_id,
	}
	var request_url: String = STEAM_SERVICE_STORE_API_URL + ENDPOINT_STORE_GET_APP_INFO
	request_url = request_url.format(store_request_query)
	var _err = http_request.request(request_url)
	#print_rich("[color=yellow]Requested appID[/color] %s | [color=red]Error[/color]: %s" % [app_id, error_string(err)])


func _on_request_completed(
			result: int,
			response_code: int,
			headers: PackedStringArray,
			body: PackedByteArray,
		) -> void:
	#print_rich("Result %s | Response %s" % [result, response_code])
	var response_json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	var game_data = response_json[str(selected_steam_app_id)]["data"]
	steam_app_data = SteamAppData.from_json(game_data)
