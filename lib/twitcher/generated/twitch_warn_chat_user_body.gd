@tool
extends RefCounted

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

class_name TwitchWarnChatUserBody

## A list that contains information about the warning.
var data: Data:
	set(val):
		data = val;
		if data != null:
			changed_data["data"] = data.to_dict();

var changed_data: Dictionary = {};

static func from_json(d: Dictionary) -> TwitchWarnChatUserBody:
	var result = TwitchWarnChatUserBody.new();
	if d.has("data") && d["data"] != null:
		result.data = Data.from_json(d["data"]);
	return result;

func to_dict() -> Dictionary:
	return changed_data;

func to_json() -> String:
	return JSON.stringify(to_dict());

## A list that contains information about the warning.
class Data extends RefCounted:
	## The ID of the twitch user to be warned.
	var user_id: String:
		set(val):
			user_id = val;
			changed_data["user_id"] = user_id;
	## A custom reason for the warning. **Max 500 chars.**
	var reason: String:
		set(val):
			reason = val;
			changed_data["reason"] = reason;

	var changed_data: Dictionary = {};

	static func from_json(d: Dictionary) -> Data:
		var result = Data.new();
		if d.has("user_id") && d["user_id"] != null:
			result.user_id = d["user_id"];
		if d.has("reason") && d["reason"] != null:
			result.reason = d["reason"];
		return result;

	func to_dict() -> Dictionary:
		return changed_data;

	func to_json() -> String:
		return JSON.stringify(to_dict());
