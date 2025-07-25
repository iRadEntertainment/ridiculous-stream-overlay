@tool
@icon("itchio_icon.svg")
extends Node
class_name ItchIOService

static var _log: TwitchLogger = TwitchLogger.new(&"ItchIOService")



func get_itch_app_data(game_url: String) -> ItchIOAppData:
	var http_request = HTTPRequest.new()
	add_child(http_request)

	var base_url := game_url.strip_edges().rstrip("/")
	var json_url := base_url + "/data.json"
	
	var err := http_request.request(json_url)
	if err != OK:
		_log.e("Error requesting Itch data: %s" % error_string(err))
		return null

	var json_result: Array = await http_request.request_completed
	var _result: int = json_result[0]
	var response_code: int = json_result[1]
	var body: PackedByteArray = json_result[3]

	if response_code != HTTPClient.RESPONSE_OK:
		_log.e("Failed to fetch Itch data.json. HTTP %s" % response_code)
		return null

	var json = JSON.parse_string(body.get_string_from_utf8())
	if typeof(json) != TYPE_DICTIONARY:
		_log.e("Invalid JSON from Itch")
		return null

	# Second request to get the HTML
	err = http_request.request(base_url)
	if err != OK:
		_log.e("Error requesting Itch HTML: %s" % error_string(err))
		return ItchIOAppData.from_json(json)

	var html_result: Array = await http_request.request_completed
	var html_code: int = html_result[1]
	var html_body: PackedByteArray = html_result[3]

	if html_code == HTTPClient.RESPONSE_OK:
		var html := html_body.get_string_from_utf8()
		var extra_info: Dictionary = scrape_html(html)
		json.merge(extra_info)
	else:
		_log.e("Could not retrieve HTML content. Skipping description/screenshot parsing.")
	http_request.queue_free()
	return ItchIOAppData.from_json(json)


func scrape_html(html: String) -> Dictionary:
	var data := {
		"description": "",
		"screenshots_thumbnails": [],
		"screenshots_full": [],
	}
	
	var desc_regex := RegEx.new()
	desc_regex.compile(r'(?s)<div class="formatted_description user_formatted">(.*?)<\/div>')
	var desc_match: RegExMatch = desc_regex.search(html)
	if desc_match:
		data["description"] = RSUtl.convert_html_to_bbcode( desc_match.get_string(1) )

	# 2. Extract screenshot_list inner HTML
	var div_regex := RegEx.new()
	div_regex.compile(r'(?s)<div class="screenshot_list">(.*?)</div>')
	var div_match := div_regex.search(html)

	if div_match:
		var screenshot_block: String = div_match.get_string(1)
		
		# 3. Extract only thumbnails
		var screenshots_thumbnails_regex := RegEx.new()
		screenshots_thumbnails_regex.compile(r'<img[^>]+src="([^"]+/\d+x\d+/[^"]+)"')
		var screenshots_thumbnails_matches: Array[RegExMatch] = screenshots_thumbnails_regex.search_all(screenshot_block)
		
		for s_match: RegExMatch in screenshots_thumbnails_matches:
			data["screenshots_thumbnails"].append(s_match.get_string(1))
		
		# 4. Extract only originals (full size)
		var screenshots_full_regex := RegEx.new()
		screenshots_full_regex.compile(r'<a[^>]+href="([^"]+\/original\/[^"]+)"')
		var screenshots_full_matches: Array[RegExMatch] = screenshots_full_regex.search_all(screenshot_block)
		
		for s_match: RegExMatch in screenshots_full_matches:
			data["screenshots_full"].append(s_match.get_string(1))
	
	return data
