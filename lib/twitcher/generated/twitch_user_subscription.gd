@tool
extends RefCounted

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

class_name TwitchUserSubscription

## An ID that identifies the broadcaster.
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
## The ID of the user that gifted the subscription. The object includes this field only if `is_gift` is **true**.
var gifter_id: String:
	set(val):
		gifter_id = val;
		changed_data["gifter_id"] = gifter_id;
## The gifter’s login name. The object includes this field only if `is_gift` is **true**.
var gifter_login: String:
	set(val):
		gifter_login = val;
		changed_data["gifter_login"] = gifter_login;
## The gifter’s display name. The object includes this field only if `is_gift` is **true**.
var gifter_name: String:
	set(val):
		gifter_name = val;
		changed_data["gifter_name"] = gifter_name;
## A Boolean value that determines whether the subscription is a gift subscription. Is **true** if the subscription was gifted.
var is_gift: bool:
	set(val):
		is_gift = val;
		changed_data["is_gift"] = is_gift;
## The type of subscription. Possible values are:      * 1000 — Tier 1 * 2000 — Tier 2 * 3000 — Tier 3
var tier: String:
	set(val):
		tier = val;
		changed_data["tier"] = tier;

var changed_data: Dictionary = {};

static func from_json(d: Dictionary) -> TwitchUserSubscription:
	var result = TwitchUserSubscription.new();
	if d.has("broadcaster_id") && d["broadcaster_id"] != null:
		result.broadcaster_id = d["broadcaster_id"];
	if d.has("broadcaster_login") && d["broadcaster_login"] != null:
		result.broadcaster_login = d["broadcaster_login"];
	if d.has("broadcaster_name") && d["broadcaster_name"] != null:
		result.broadcaster_name = d["broadcaster_name"];
	if d.has("gifter_id") && d["gifter_id"] != null:
		result.gifter_id = d["gifter_id"];
	if d.has("gifter_login") && d["gifter_login"] != null:
		result.gifter_login = d["gifter_login"];
	if d.has("gifter_name") && d["gifter_name"] != null:
		result.gifter_name = d["gifter_name"];
	if d.has("is_gift") && d["is_gift"] != null:
		result.is_gift = d["is_gift"];
	if d.has("tier") && d["tier"] != null:
		result.tier = d["tier"];
	return result;

func to_dict() -> Dictionary:
	return changed_data;

func to_json() -> String:
	return JSON.stringify(to_dict());
