@tool
extends RefCounted

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

class_name TwitchStartCommercialResponse

## An array that contains a single object with the status of your start commercial request.
var data: Array[Data]:
	set(val):
		data = val;
		changed_data["data"] = [];
		if data != null:
			for value in data:
				changed_data["data"].append(value.to_dict());

var changed_data: Dictionary = {};

static func from_json(d: Dictionary) -> TwitchStartCommercialResponse:
	var result = TwitchStartCommercialResponse.new();
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
	## The length of the commercial you requested. If you request a commercial that’s longer than 180 seconds, the API uses 180 seconds.
	var length: int:
		set(val):
			length = val;
			changed_data["length"] = length;
	## A message that indicates whether Twitch was able to serve an ad.
	var message: String:
		set(val):
			message = val;
			changed_data["message"] = message;
	## The number of seconds you must wait before running another commercial.
	var retry_after: int:
		set(val):
			retry_after = val;
			changed_data["retry_after"] = retry_after;

	var changed_data: Dictionary = {};

	static func from_json(d: Dictionary) -> Data:
		var result = Data.new();
		if d.has("length") && d["length"] != null:
			result.length = d["length"];
		if d.has("message") && d["message"] != null:
			result.message = d["message"];
		if d.has("retry_after") && d["retry_after"] != null:
			result.retry_after = d["retry_after"];
		return result;

	func to_dict() -> Dictionary:
		return changed_data;

	func to_json() -> String:
		return JSON.stringify(to_dict());
