@tool
extends Resource
class_name ItchIOAppData

@export var id: int
@export var title: String
@export var authors: Array[Dictionary] = [] # Each with "name" and "url"
@export var tags: Array[String] = []
@export var links: Dictionary = {} # "self", "comments"
@export var cover_image: String = ""
@export var price: String = ""
@export var description: String = ""
@export var screenshots_thumbnails: Array[String] = []
@export var screenshots_full: Array[String] = []

var is_free: bool:
	get(): return currency_to_float(price) == 0.0

var url: String:
	get():
		return links.get("self", "")

var comments_url: String:
	get():
		return links.get("comments", "")


func to_json() -> Dictionary:
	var data := {}
	data["id"] = id
	data["title"] = title
	data["authors"] = authors.duplicate()
	data["tags"] = tags.duplicate()
	data["links"] = links.duplicate()
	data["cover_image"] = cover_image
	data["price"] = price
	data["description"] = description
	data["screenshots"] = []
	for _url: String in screenshots_thumbnails:
		data["screenshots_thumbnails"].append(_url)
	for _url: String in screenshots_full:
		data["screenshots_full"].append(_url)
	return data


static func from_json(data: Dictionary) -> ItchIOAppData:
	var app := ItchIOAppData.new()
	app.id = data.get("id", 0)
	app.title = data.get("title", "")
	app.cover_image = data.get("cover_image", "")
	app.price = data.get("price", "")
	# Authors
	for author in data.get("authors", []):
		if typeof(author) == TYPE_DICTIONARY:
			app.authors.append(author)
	# Tags
	for tag in data.get("tags", []):
		app.tags.append(str(tag))
	# Links
	app.links = data.get("links", {}).duplicate()
	
	app.description = data.get("description", "")
	for _url: String in data.get("screenshots_thumbnails", []):
		app.screenshots_thumbnails.append(str(_url))
	for _url: String in data.get("screenshots_full", []):
		app.screenshots_full.append(str(_url))
	return app


static func currency_to_float(currency_str: String) -> float:
	var regex := RegEx.new()
	regex.compile(r"[\d\.]+")
	
	var currency_match := regex.search(currency_str)
	if currency_match:
		return currency_match.get_string().to_float()
	else:
		return 0.0
