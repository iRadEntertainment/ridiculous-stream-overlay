@tool
extends RefCounted

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

class_name TwitchCustomRewardRedemption

## The ID that uniquely identifies the broadcaster.
var broadcaster_id: String:
	set(val):
		broadcaster_id = val;
		changed_data["broadcaster_id"] = broadcaster_id;
## The broadcaster’s login name.
var broadcaster_login: String:
	set(val):
		broadcaster_login = val;
		changed_data["broadcaster_login"] = broadcaster_login;
## The broadcaster’s display name.
var broadcaster_name: String:
	set(val):
		broadcaster_name = val;
		changed_data["broadcaster_name"] = broadcaster_name;
## The ID that uniquely identifies this redemption..
var id: String:
	set(val):
		id = val;
		changed_data["id"] = id;
## The ID of the user that redeemed the reward.
var user_id: String:
	set(val):
		user_id = val;
		changed_data["user_id"] = user_id;
## The user’s display name.
var user_name: String:
	set(val):
		user_name = val;
		changed_data["user_name"] = user_name;
## The user’s login name.
var user_login: String:
	set(val):
		user_login = val;
		changed_data["user_login"] = user_login;
## An object that describes the reward that the user redeemed.
var reward: Reward:
	set(val):
		reward = val;
		if reward != null:
			changed_data["reward"] = reward.to_dict();
## The text that the user entered at the prompt when they redeemed the reward; otherwise, an empty string if user input was not required.
var user_input: String:
	set(val):
		user_input = val;
		changed_data["user_input"] = user_input;
## The state of the redemption. Possible values are:      * CANCELED * FULFILLED * UNFULFILLED
var status: String:
	set(val):
		status = val;
		changed_data["status"] = status;
## The date and time of when the reward was redeemed, in RFC3339 format.
var redeemed_at: Variant:
	set(val):
		redeemed_at = val;
		changed_data["redeemed_at"] = redeemed_at;

var changed_data: Dictionary = {};

static func from_json(d: Dictionary) -> TwitchCustomRewardRedemption:
	var result = TwitchCustomRewardRedemption.new();
	if d.has("broadcaster_id") && d["broadcaster_id"] != null:
		result.broadcaster_id = d["broadcaster_id"];
	if d.has("broadcaster_login") && d["broadcaster_login"] != null:
		result.broadcaster_login = d["broadcaster_login"];
	if d.has("broadcaster_name") && d["broadcaster_name"] != null:
		result.broadcaster_name = d["broadcaster_name"];
	if d.has("id") && d["id"] != null:
		result.id = d["id"];
	if d.has("user_id") && d["user_id"] != null:
		result.user_id = d["user_id"];
	if d.has("user_name") && d["user_name"] != null:
		result.user_name = d["user_name"];
	if d.has("user_login") && d["user_login"] != null:
		result.user_login = d["user_login"];
	if d.has("reward") && d["reward"] != null:
		result.reward = Reward.from_json(d["reward"]);
	if d.has("user_input") && d["user_input"] != null:
		result.user_input = d["user_input"];
	if d.has("status") && d["status"] != null:
		result.status = d["status"];
	if d.has("redeemed_at") && d["redeemed_at"] != null:
		result.redeemed_at = d["redeemed_at"];
	return result;

func to_dict() -> Dictionary:
	return changed_data;

func to_json() -> String:
	return JSON.stringify(to_dict());

## An object that describes the reward that the user redeemed.
class Reward extends RefCounted:
	## The ID that uniquely identifies the reward.
	var id: String:
		set(val):
			id = val;
			changed_data["id"] = id;
	## The reward’s title.
	var title: String:
		set(val):
			title = val;
			changed_data["title"] = title;
	## The prompt displayed to the viewer if user input is required.
	var prompt: String:
		set(val):
			prompt = val;
			changed_data["prompt"] = prompt;
	## The reward’s cost, in Channel Points.
	var cost: int:
		set(val):
			cost = val;
			changed_data["cost"] = cost;

	var changed_data: Dictionary = {};

	static func from_json(d: Dictionary) -> Reward:
		var result = Reward.new();
		if d.has("id") && d["id"] != null:
			result.id = d["id"];
		if d.has("title") && d["title"] != null:
			result.title = d["title"];
		if d.has("prompt") && d["prompt"] != null:
			result.prompt = d["prompt"];
		if d.has("cost") && d["cost"] != null:
			result.cost = d["cost"];
		return result;

	func to_dict() -> Dictionary:
		return changed_data;

	func to_json() -> String:
		return JSON.stringify(to_dict());
