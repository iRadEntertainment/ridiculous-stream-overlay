@tool
extends RefCounted

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

class_name TwitchSearchChannelsResponse

## The list of channels that match the query. The list is empty if there are no matches.
var data: Array[TwitchChannel]:
	set(val):
		data = val;
		changed_data["data"] = [];
		if data != null:
			for value in data:
				changed_data["data"].append(value.to_dict());

var changed_data: Dictionary = {};

static func from_json(d: Dictionary) -> TwitchSearchChannelsResponse:
	var result = TwitchSearchChannelsResponse.new();
	if d.has("data") && d["data"] != null:
		for value in d["data"]:
			result.data.append(TwitchChannel.from_json(value));
	return result;

func to_dict() -> Dictionary:
	return changed_data;

func to_json() -> String:
	return JSON.stringify(to_dict());
