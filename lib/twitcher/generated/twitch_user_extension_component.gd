@tool
extends RefCounted

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

class_name TwitchUserExtensionComponent

## A Boolean value that determines the extension’s activation state. If **false**, the user has not configured a component extension.
var active: bool:
	set(val):
		active = val;
		changed_data["active"] = active;
## An ID that identifies the extension.
var id: String:
	set(val):
		id = val;
		changed_data["id"] = id;
## The extension’s version.
var version: String:
	set(val):
		version = val;
		changed_data["version"] = version;
## The extension’s name.
var name: String:
	set(val):
		name = val;
		changed_data["name"] = name;
## The x-coordinate where the extension is placed.
var x: int:
	set(val):
		x = val;
		changed_data["x"] = x;
## The y-coordinate where the extension is placed.
var y: int:
	set(val):
		y = val;
		changed_data["y"] = y;

var changed_data: Dictionary = {};

static func from_json(d: Dictionary) -> TwitchUserExtensionComponent:
	var result = TwitchUserExtensionComponent.new();
	if d.has("active") && d["active"] != null:
		result.active = d["active"];
	if d.has("id") && d["id"] != null:
		result.id = d["id"];
	if d.has("version") && d["version"] != null:
		result.version = d["version"];
	if d.has("name") && d["name"] != null:
		result.name = d["name"];
	if d.has("x") && d["x"] != null:
		result.x = d["x"];
	if d.has("y") && d["y"] != null:
		result.y = d["y"];
	return result;

func to_dict() -> Dictionary:
	return changed_data;

func to_json() -> String:
	return JSON.stringify(to_dict());
