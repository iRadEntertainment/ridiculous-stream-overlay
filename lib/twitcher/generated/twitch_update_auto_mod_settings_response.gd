@tool
extends RefCounted

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

class_name TwitchUpdateAutoModSettingsResponse

## The list of AutoMod settings. The list contains a single object that contains all the AutoMod settings.
var data: Array[TwitchAutoModSettings]:
	set(val):
		data = val;
		changed_data["data"] = [];
		if data != null:
			for value in data:
				changed_data["data"].append(value.to_dict());

var changed_data: Dictionary = {};

static func from_json(d: Dictionary) -> TwitchUpdateAutoModSettingsResponse:
	var result = TwitchUpdateAutoModSettingsResponse.new();
	if d.has("data") && d["data"] != null:
		for value in d["data"]:
			result.data.append(TwitchAutoModSettings.from_json(value));
	return result;

func to_dict() -> Dictionary:
	return changed_data;

func to_json() -> String:
	return JSON.stringify(to_dict());
