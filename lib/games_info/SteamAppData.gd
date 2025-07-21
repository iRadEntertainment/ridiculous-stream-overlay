@tool
extends Resource
class_name SteamAppData


@export var type: String
@export var name: String
@export var steam_app_id: int
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

@export var price_currency: String
@export var price_initial: int
@export var price_final: int
@export var price_discount_percent: int
@export var price_initial_formatted: String
@export var price_final_formatted: String

@export var categories: Array[Dictionary] = []
@export var dlc: Array[int] = []
@export var packages: Array[int] = []

@export var total_achievements: int = 0
@export var highlighted_achievements: Array[Dictionary] = []

@export var pc_requirements: String = ""
@export var mac_requirements: String = ""
@export var linux_requirements: String = ""

@export var support_email: String = ""
@export var support_url: String = ""

@export var background_image: String = ""
@export var background_image_raw: String = ""


var short_url: String:
	get(): return "https://store.steampowered.com/app/%d" % steam_app_id

var seo_url: String:
	get():
		if name.is_empty():
			return short_url
		var slug = name.strip_edges().replace(" ", "_")
		return "https://store.steampowered.com/app/%d/%s" % [steam_app_id, slug]

var protocol_url: String:
	get(): return "steam://store/%d" % steam_app_id

var s_team_url: String:
	get(): return "https://s.team/a/%d" % steam_app_id

var utm_url: String:
	get():
		# Optional: You could allow setting UTM fields via other vars if needed
		return "%s?utm_source=default&utm_medium=link&utm_campaign=default" % short_url


func to_json() -> Dictionary:
	var data := {}
	data["type"] = type
	data["name"] = name
	data["steam_app_id"] = steam_app_id
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
	data["developers"] = developers
	data["publishers"] = publishers
	data["genres"] = genres
	data["categories"] = categories
	data["dlc"] = dlc
	data["packages"] = packages
	# Price overview
	data["price_overview"] = {
		"currency": price_currency,
		"initial": price_initial,
		"final": price_final,
		"discount_percent": price_discount_percent,
		"initial_formatted": price_initial_formatted,
		"final_formatted": price_final_formatted
	}
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
	# Achievements
	data["achievements"] = {
		"total": total_achievements,
		"highlighted": highlighted_achievements.duplicate()
	}
	# Requirements
	data["pc_requirements"] = { "minimum": pc_requirements }
	data["mac_requirements"] = mac_requirements
	data["linux_requirements"] = linux_requirements
	# Support info
	data["support_info"] = {
		"email": support_email,
		"url": support_url
	}
	# Background
	data["background"] = background_image
	data["background_raw"] = background_image_raw
	return data


func save_as_file(filepath: String) -> void:
	var file = FileAccess.open(filepath, FileAccess.WRITE)
	if file:
		var json_text = JSON.stringify(to_json(), "\t") # Pretty print with tabs
		file.store_string(json_text)
		file.close()
	else:
		push_error("Failed to open file for writing: %s" % filepath)


static func from_json(data: Dictionary) -> SteamAppData:
	var app = SteamAppData.new()
	app.type = data.get("type", "")
	app.name = data.get("name", "")
	app.steam_app_id = data.get("steam_app_id", 0)
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
	for d in data.get("developers", []):
		app.developers.append(str(d))
	for p in data.get("publishers", []):
		app.publishers.append(str(p))
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
	# Pricing
	var price = data.get("price_overview", {})
	app.price_currency = price.get("currency", "")
	app.price_initial = price.get("initial", 0)
	app.price_final = price.get("final", 0)
	app.price_discount_percent = price.get("discount_percent", 0)
	app.price_initial_formatted = price.get("initial_formatted", "")
	app.price_final_formatted = price.get("final_formatted", "")
	# DLC and Packages
	for d in data.get("dlc", []):
		app.dlc.append(int(d))
	for p in data.get("packages", []):
		app.packages.append(int(p))
	# Categories
	for cat in data.get("categories", []):
		if typeof(cat) == TYPE_DICTIONARY:
			app.categories.append(cat)
	# Achievements
	var ach = data.get("achievements", {})
	app.total_achievements = int(ach.get("total", 0))
	for h in ach.get("highlighted", []):
		app.highlighted_achievements.append(h)
	# System Requirements
	app.pc_requirements = data.get("pc_requirements", {}).get("minimum", "")
	app.mac_requirements = str(data.get("mac_requirements", ""))
	app.linux_requirements = str(data.get("linux_requirements", ""))
	# Support Info
	var support = data.get("support_info", {})
	app.support_email = support.get("email", "")
	app.support_url = support.get("url", "")
	# Background Images
	app.background_image = data.get("background", "")
	app.background_image_raw = data.get("background_raw", "")
	return app


static func from_file(filepath: String) -> SteamAppData:
	if not FileAccess.file_exists(filepath):
		push_error("File does not exist: %s" % filepath)
		return null
	
	var file = FileAccess.open(filepath, FileAccess.READ)
	if not file:
		push_error("Failed to open file for reading: %s" % filepath)
		return null
	
	var content = file.get_as_text()
	file.close()
	
	var result = JSON.parse_string(content)
	if typeof(result) != TYPE_DICTIONARY:
		push_error("Failed to parse JSON or invalid format in: %s" % filepath)
		return null
	
	return SteamAppData.from_json(result)
