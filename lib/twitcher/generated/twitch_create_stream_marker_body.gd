@tool
extends RefCounted

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

class_name TwitchCreateStreamMarkerBody

## The ID of the broadcaster that’s streaming content. This ID must match the user ID in the access token or the user in the access token must be one of the broadcaster’s editors.
var user_id: String:
	set(val):
		user_id = val;
		changed_data["user_id"] = user_id;
## A short description of the marker to help the user remember why they marked the location. The maximum length of the description is 140 characters.
var description: String:
	set(val):
		description = val;
		changed_data["description"] = description;

var changed_data: Dictionary = {};

static func from_json(d: Dictionary) -> TwitchCreateStreamMarkerBody:
	var result = TwitchCreateStreamMarkerBody.new();
	if d.has("user_id") && d["user_id"] != null:
		result.user_id = d["user_id"];
	if d.has("description") && d["description"] != null:
		result.description = d["description"];
	return result;

func to_dict() -> Dictionary:
	return changed_data;

func to_json() -> String:
	return JSON.stringify(to_dict());
