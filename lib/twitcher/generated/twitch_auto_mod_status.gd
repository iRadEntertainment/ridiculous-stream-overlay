@tool
extends RefCounted

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

class_name TwitchAutoModStatus

## The caller-defined ID passed in the request.
var msg_id: String:
	set(val):
		msg_id = val;
		changed_data["msg_id"] = msg_id;
## A Boolean value that indicates whether Twitch would approve the message for chat or hold it for moderator review or block it from chat. Is **true** if Twitch would approve the message; otherwise, **false** if Twitch would hold the message for moderator review or block it from chat.
var is_permitted: bool:
	set(val):
		is_permitted = val;
		changed_data["is_permitted"] = is_permitted;

var changed_data: Dictionary = {};

static func from_json(d: Dictionary) -> TwitchAutoModStatus:
	var result = TwitchAutoModStatus.new();
	if d.has("msg_id") && d["msg_id"] != null:
		result.msg_id = d["msg_id"];
	if d.has("is_permitted") && d["is_permitted"] != null:
		result.is_permitted = d["is_permitted"];
	return result;

func to_dict() -> Dictionary:
	return changed_data;

func to_json() -> String:
	return JSON.stringify(to_dict());
