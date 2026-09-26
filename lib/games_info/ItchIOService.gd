@tool
@icon("itchio_icon.svg")
extends Node
class_name ItchIOService

static var _log: TwitchLogger = TwitchLogger.new(&"ItchIOService")



func get_itch_app_data(game_url: String) -> ItchIOAppData:
	var http_request = HTTPRequest.new()
	http_request.timeout = 30.0
	add_child(http_request)

	var base_url := game_url.strip_edges().rstrip("/")
	var json_url := base_url + "/data.json"
	_log.i("Fetching itch.io JSON: %s" % json_url)
	
	var err := http_request.request(json_url)
	if err != OK:
		_log.e("Could not start itch.io JSON request (%s): %s." % [base_url, error_string(err)])
		http_request.queue_free()
		return null

	var json_result: Array = await http_request.request_completed
	var result: int = json_result[0]
	var response_code: int = json_result[1]
	var body: PackedByteArray = json_result[3]

	if result != HTTPRequest.RESULT_SUCCESS or response_code != HTTPClient.RESPONSE_OK:
		_log.e("itch.io JSON request failed (%s): transport result=%d, HTTP=%d." % [base_url, result, response_code])
		http_request.queue_free()
		return null

	var json = JSON.parse_string(body.get_string_from_utf8())
	if typeof(json) != TYPE_DICTIONARY:
		_log.e("Invalid itch.io JSON response (%s): expected an object." % base_url)
		http_request.queue_free()
		return null
	if int(json.get("id", 0)) <= 0 or not json.get("links") is Dictionary or str(json.links.get("self", "")).is_empty():
		_log.w("itch.io metadata missing a valid game ID or self URL (%s)." % base_url)
		http_request.queue_free()
		return null

	# Second request to get the HTML
	_log.i("Fetching itch.io HTML: %s" % base_url)
	err = http_request.request(base_url)
	if err != OK:
		_log.e("Could not start itch.io HTML request (%s): %s." % [base_url, error_string(err)])
		http_request.queue_free()
		return null

	var html_result: Array = await http_request.request_completed
	http_request.queue_free()
	var html_code: int = html_result[1]
	var html_body: PackedByteArray = html_result[3]

	if html_result[0] == HTTPRequest.RESULT_SUCCESS and html_code == HTTPClient.RESPONSE_OK:
		var html := html_body.get_string_from_utf8()
		var extra_info: Dictionary = scrape_html(html)
		json.merge(extra_info)
	else:
		# A partial refresh must not overwrite saved descriptions/screenshots.
		_log.e("itch.io HTML request failed (%s): transport result=%d, HTTP=%d. Keeping previous game info." % [base_url, html_result[0], html_code])
		return null
	_log.i("Retrieved itch.io metadata and HTML: %s" % base_url)
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
