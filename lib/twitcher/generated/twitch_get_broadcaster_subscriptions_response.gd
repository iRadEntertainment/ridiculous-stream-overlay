@tool
extends RefCounted

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

class_name TwitchGetBroadcasterSubscriptionsResponse

## The list of users that subscribe to the broadcaster. The list is empty if the broadcaster has no subscribers.
var data: Array[TwitchBroadcasterSubscription]:
	set(val):
		data = val;
		changed_data["data"] = [];
		if data != null:
			for value in data:
				changed_data["data"].append(value.to_dict());
## Contains the information used to page through the list of results. The object is empty if there are no more pages left to page through. [Read More](https://dev.twitch.tv/docs/api/guide#pagination)
var pagination: Pagination:
	set(val):
		pagination = val;
		if pagination != null:
			changed_data["pagination"] = pagination.to_dict();
## The current number of subscriber points earned by this broadcaster. Points are based on the subscription tier of each user that subscribes to this broadcaster. For example, a Tier 1 subscription is worth 1 point, Tier 2 is worth 2 points, and Tier 3 is worth 6 points. The number of points determines the number of emote slots that are unlocked for the broadcaster (see [Subscriber Emote Slots](https://help.twitch.tv/s/article/subscriber-emote-guide#emoteslots)).
var points: int:
	set(val):
		points = val;
		changed_data["points"] = points;
## The total number of users that subscribe to this broadcaster.
var total: int:
	set(val):
		total = val;
		changed_data["total"] = total;

var changed_data: Dictionary = {};

static func from_json(d: Dictionary) -> TwitchGetBroadcasterSubscriptionsResponse:
	var result = TwitchGetBroadcasterSubscriptionsResponse.new();
	if d.has("data") && d["data"] != null:
		for value in d["data"]:
			result.data.append(TwitchBroadcasterSubscription.from_json(value));
	if d.has("pagination") && d["pagination"] != null:
		result.pagination = Pagination.from_json(d["pagination"]);
	if d.has("points") && d["points"] != null:
		result.points = d["points"];
	if d.has("total") && d["total"] != null:
		result.total = d["total"];
	return result;

func to_dict() -> Dictionary:
	return changed_data;

func to_json() -> String:
	return JSON.stringify(to_dict());

## Contains the information used to page through the list of results. The object is empty if there are no more pages left to page through. [Read More](https://dev.twitch.tv/docs/api/guide#pagination)
class Pagination extends RefCounted:
	## The cursor used to get the next or previous page of results. Use the cursor to set the request’s _after_ or _before_ query parameter depending on whether you’re paging forwards or backwards.
	var cursor: String:
		set(val):
			cursor = val;
			changed_data["cursor"] = cursor;

	var changed_data: Dictionary = {};

	static func from_json(d: Dictionary) -> Pagination:
		var result = Pagination.new();
		if d.has("cursor") && d["cursor"] != null:
			result.cursor = d["cursor"];
		return result;

	func to_dict() -> Dictionary:
		return changed_data;

	func to_json() -> String:
		return JSON.stringify(to_dict());
