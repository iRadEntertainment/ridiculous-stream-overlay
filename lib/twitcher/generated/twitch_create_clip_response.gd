@tool
extends RefCounted

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

class_name TwitchCreateClipResponse

## 
var data: Array[Data]:
	set(val):
		data = val;
		changed_data["data"] = [];
		if data != null:
			for value in data:
				changed_data["data"].append(value.to_dict());

var changed_data: Dictionary = {};

static func from_json(d: Dictionary) -> TwitchCreateClipResponse:
	var result = TwitchCreateClipResponse.new();
	if d.has("data") && d["data"] != null:
		for value in d["data"]:
			result.data.append(Data.from_json(value));
	return result;

func to_dict() -> Dictionary:
	return changed_data;

func to_json() -> String:
	return JSON.stringify(to_dict());

## 
class Data extends RefCounted:
	## A URL that you can use to edit the clip’s title, identify the part of the clip to publish, and publish the clip. [Learn More](https://help.twitch.tv/s/article/how-to-use-clips)      The URL is valid for up to 24 hours or until the clip is published, whichever comes first.
	var edit_url: String:
		set(val):
			edit_url = val;
			changed_data["edit_url"] = edit_url;
	## An ID that uniquely identifies the clip.
	var id: String:
		set(val):
			id = val;
			changed_data["id"] = id;

	var changed_data: Dictionary = {};

	static func from_json(d: Dictionary) -> Data:
		var result = Data.new();
		if d.has("edit_url") && d["edit_url"] != null:
			result.edit_url = d["edit_url"];
		if d.has("id") && d["id"] != null:
			result.id = d["id"];
		return result;

	func to_dict() -> Dictionary:
		return changed_data;

	func to_json() -> String:
		return JSON.stringify(to_dict());
