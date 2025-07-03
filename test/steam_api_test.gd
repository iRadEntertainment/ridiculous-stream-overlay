@tool
extends Node

const STEAM_SERVICE_URL = "https://api.steampowered.com/IStoreService/"
const ENDPOINT_GET_APP_INFO = "GetAppInfo/v1/?key={steamkey}&appid={appid}&include_games=true"
enum Games{
	BLOOD_AND_MEAD,
	RIDICULOUS_SHIPPING,
	MEMORI,
	BLOCK_SHOP,
	FIELD_OF_HEROES,
	ZOOIKA,
	KOOK,
}
const APP_IDS: Dictionary[Games, int] = {
	Games.BLOOD_AND_MEAD: 1081830,
	Games.RIDICULOUS_SHIPPING: 2649940,
	Games.MEMORI: 1712700,
	Games.BLOCK_SHOP: 2731590,
	Games.FIELD_OF_HEROES: 1267290,
	Games.ZOOIKA: 2994730,
	Games.KOOK: 2329690,
}

@onready var http_request: HTTPRequest = $HTTPRequest
@export_tool_button("Run Test", "Button") var _test_btn = run_test
@export() var selected_game: Games:
	set(val):
		selected_game = val
		selected_app_id = APP_IDS[selected_game]

@export var app_data: SteamAppData


var selected_app_id: int
var api_steamkey: String = ""


func _ready() -> void:
	http_request.request_completed.connect(_on_request_completed)


func run_test() -> void:
	var file_steam_key = FileAccess.open("res://api_steam.key", FileAccess.READ)
	api_steamkey = file_steam_key.get_as_text().strip_edges().uri_encode()
	get_steam_game_description(selected_app_id)


func get_steam_game_description(app_id: int) -> void:
	# build request
	var request_query: Dictionary = {
		"steamkey": api_steamkey,
		"appid": app_id,
	}
	var request_url: String = STEAM_SERVICE_URL + ENDPOINT_GET_APP_INFO
	request_url = request_url.format(request_query)
	
	var alt_url = "https://store.steampowered.com/api/appdetails?appids={appid}".format(request_query)
	var err = http_request.request(alt_url)
	#print_rich("[color=yellow]Requested appID[/color] %s | [color=red]Error[/color]: %s" % [app_id, error_string(err)])


func _on_request_completed(
			result: int,
			response_code: int,
			headers: PackedStringArray,
			body: PackedByteArray,
		) -> void:
	#print_rich("Result %s | Response %s" % [result, response_code])
	var response_json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	var game_data = response_json[str(selected_app_id)]["data"]
	app_data = SteamAppData.from_json(game_data)
	if app_data:
		$RichTextLabel.text = app_data.detailed_description_bbcode
