@tool
extends RefCounted

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

class_name TwitchChannelInformation

## An ID that uniquely identifies the broadcaster.
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
## The broadcaster’s preferred language. The value is an ISO 639-1 two-letter language code (for example, _en_ for English). The value is set to “other” if the language is not a Twitch supported language.
var broadcaster_language: String:
	set(val):
		broadcaster_language = val;
		changed_data["broadcaster_language"] = broadcaster_language;
## The name of the game that the broadcaster is playing or last played. The value is an empty string if the broadcaster has never played a game.
var game_name: String:
	set(val):
		game_name = val;
		changed_data["game_name"] = game_name;
## An ID that uniquely identifies the game that the broadcaster is playing or last played. The value is an empty string if the broadcaster has never played a game.
var game_id: String:
	set(val):
		game_id = val;
		changed_data["game_id"] = game_id;
## The title of the stream that the broadcaster is currently streaming or last streamed. The value is an empty string if the broadcaster has never streamed.
var title: String:
	set(val):
		title = val;
		changed_data["title"] = title;
## The value of the broadcaster’s stream delay setting, in seconds. This field’s value defaults to zero unless 1) the request specifies a user access token, 2) the ID in the _broadcaster\_id_ query parameter matches the user ID in the access token, and 3) the broadcaster has partner status and they set a non-zero stream delay value.
var delay: int:
	set(val):
		delay = val;
		changed_data["delay"] = delay;
## The tags applied to the channel.
var tags: Array[String]:
	set(val):
		tags = val;
		changed_data["tags"] = [];
		if tags != null:
			for value in tags:
				changed_data["tags"].append(value);
## The CCLs applied to the channel.
var content_classification_labels: Array[String]:
	set(val):
		content_classification_labels = val;
		changed_data["content_classification_labels"] = [];
		if content_classification_labels != null:
			for value in content_classification_labels:
				changed_data["content_classification_labels"].append(value);
## Boolean flag indicating if the channel has branded content.
var is_branded_content: bool:
	set(val):
		is_branded_content = val;
		changed_data["is_branded_content"] = is_branded_content;

var changed_data: Dictionary = {};

static func from_json(d: Dictionary) -> TwitchChannelInformation:
	var result = TwitchChannelInformation.new();
	if d.has("broadcaster_id") && d["broadcaster_id"] != null:
		result.broadcaster_id = d["broadcaster_id"];
	if d.has("broadcaster_login") && d["broadcaster_login"] != null:
		result.broadcaster_login = d["broadcaster_login"];
	if d.has("broadcaster_name") && d["broadcaster_name"] != null:
		result.broadcaster_name = d["broadcaster_name"];
	if d.has("broadcaster_language") && d["broadcaster_language"] != null:
		result.broadcaster_language = d["broadcaster_language"];
	if d.has("game_name") && d["game_name"] != null:
		result.game_name = d["game_name"];
	if d.has("game_id") && d["game_id"] != null:
		result.game_id = d["game_id"];
	if d.has("title") && d["title"] != null:
		result.title = d["title"];
	if d.has("delay") && d["delay"] != null:
		result.delay = d["delay"];
	if d.has("tags") && d["tags"] != null:
		for value in d["tags"]:
			result.tags.append(value);
	if d.has("content_classification_labels") && d["content_classification_labels"] != null:
		for value in d["content_classification_labels"]:
			result.content_classification_labels.append(value);
	if d.has("is_branded_content") && d["is_branded_content"] != null:
		result.is_branded_content = d["is_branded_content"];
	return result;

func to_dict() -> Dictionary:
	return changed_data;

func to_json() -> String:
	return JSON.stringify(to_dict());
