@tool
extends RefCounted

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

class_name TwitchSendExtensionChatMessageBody

## The message. The message may contain a maximum of 280 characters.
var text: String:
	set(val):
		text = val;
		changed_data["text"] = text;
## The ID of the extension that’s sending the chat message.
var extension_id: String:
	set(val):
		extension_id = val;
		changed_data["extension_id"] = extension_id;
## The extension’s version number.
var extension_version: String:
	set(val):
		extension_version = val;
		changed_data["extension_version"] = extension_version;

var changed_data: Dictionary = {};

static func from_json(d: Dictionary) -> TwitchSendExtensionChatMessageBody:
	var result = TwitchSendExtensionChatMessageBody.new();
	if d.has("text") && d["text"] != null:
		result.text = d["text"];
	if d.has("extension_id") && d["extension_id"] != null:
		result.extension_id = d["extension_id"];
	if d.has("extension_version") && d["extension_version"] != null:
		result.extension_version = d["extension_version"];
	return result;

func to_dict() -> Dictionary:
	return changed_data;

func to_json() -> String:
	return JSON.stringify(to_dict());
