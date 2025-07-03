@tool
extends Resource
class_name SteamAppData


@export var type: String
@export var name: String
@export var steam_appid: int
@export var required_age: int
@export var is_free: bool
@export var short_description: String
@export var detailed_description: String
var detailed_description_bbcode: String:
	get(): return RSUtl.convert_html_to_bbcode(detailed_description)
@export var header_image: String
@export var capsule_image: String
@export var capsule_imagev5: String
@export var website: String
@export var developers: Array[String] = []
@export var publishers: Array[String] = []
@export var platforms: Dictionary
@export var genres: Array[Dictionary] = []
@export var release_date: Dictionary

@export var screenshots_full: Array[String] = []
@export var screenshots_thumbs: Array[String] = []

@export var trailer_mp4: Dictionary  # { "480": String, "max": String }
@export var trailer_webm: Dictionary # { "480": String, "max": String }
@export var trailer_thumbnail: String


var short_url: String:
	get(): return "https://store.steampowered.com/app/%d" % steam_appid

var seo_url: String:
	get():
		if name.is_empty():
			return short_url
		var slug = name.strip_edges().replace(" ", "_")
		return "https://store.steampowered.com/app/%d/%s" % [steam_appid, slug]

var protocol_url: String:
	get(): return "steam://store/%d" % steam_appid

var s_team_url: String:
	get(): return "https://s.team/a/%d" % steam_appid

var utm_url: String:
	get():
		# Optional: You could allow setting UTM fields via other vars if needed
		return "%s?utm_source=default&utm_medium=link&utm_campaign=default" % short_url


func to_json() -> Dictionary:
	var data := {}

	data["type"] = type
	data["name"] = name
	data["steam_appid"] = steam_appid
	data["required_age"] = required_age
	data["is_free"] = is_free
	data["short_description"] = short_description
	data["detailed_description"] = detailed_description
	data["header_image"] = header_image
	data["capsule_image"] = capsule_image
	data["capsule_imagev5"] = capsule_imagev5
	data["website"] = website
	data["platforms"] = platforms
	data["release_date"] = release_date

	data["developers"] = developers.duplicate()
	data["publishers"] = publishers.duplicate()
	data["genres"] = genres.duplicate()

	# Screenshots
	var screenshots := []
	for i in screenshots_full.size():
		screenshots.append({
			"path_full": screenshots_full[i],
			"path_thumbnail": screenshots_thumbs[i] if i < screenshots_thumbs.size() else ""
		})
	data["screenshots"] = screenshots

	# Trailer
	if trailer_mp4.size() > 0 or trailer_webm.size() > 0 or not trailer_thumbnail.is_empty():
		data["movies"] = [{
			"mp4": trailer_mp4,
			"webm": trailer_webm,
			"thumbnail": trailer_thumbnail
		}]

	return data



static func from_json(data: Dictionary) -> SteamAppData:
	var app = SteamAppData.new()
	
	app.type = data.get("type", "")
	app.name = data.get("name", "")
	app.steam_appid = data.get("steam_appid", 0)
	app.required_age = data.get("required_age", 0)
	app.is_free = data.get("is_free", false)
	app.short_description = data.get("short_description", "")
	app.detailed_description = data.get("detailed_description", "")
	app.header_image = data.get("header_image", "")
	app.capsule_image = data.get("capsule_image", "")
	app.capsule_imagev5 = data.get("capsule_imagev5", "")
	app.website = data.get("website", "") if data.get("website", "") else ""
	app.platforms = data.get("platforms", {})
	app.release_date = data.get("release_date", {})

	# Typed Array[String]: developers
	for d in data.get("developers", []):
		app.developers.append(str(d))

	# Typed Array[String]: publishers
	for p in data.get("publishers", []):
		app.publishers.append(str(p))

	# Typed Array[Dictionary]: genres
	for g in data.get("genres", []):
		if typeof(g) == TYPE_DICTIONARY:
			app.genres.append(g)

	# Screenshots: full + thumbnails
	for ss in data.get("screenshots", []):
		app.screenshots_full.append(str(ss.get("path_full", "")))
		app.screenshots_thumbs.append(str(ss.get("path_thumbnail", "")))

	# Trailer (first movie only)
	var movies = data.get("movies", [])
	if movies.size() > 0:
		var trailer = movies[0]
		app.trailer_mp4 = trailer.get("mp4", {})
		app.trailer_webm = trailer.get("webm", {})
		app.trailer_thumbnail = trailer.get("thumbnail", "")

	return app
