@tool
extends RefCounted

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

class_name TwitchGetChannelGuestStarSettingsResponse

## Flag determining if Guest Star moderators have access to control whether a guest is live once assigned to a slot.
var is_moderator_send_live_enabled: bool:
	set(val):
		is_moderator_send_live_enabled = val;
		changed_data["is_moderator_send_live_enabled"] = is_moderator_send_live_enabled;
## Number of slots the Guest Star call interface will allow the host to add to a call. Required to be between 1 and 6.
var slot_count: int:
	set(val):
		slot_count = val;
		changed_data["slot_count"] = slot_count;
## Flag determining if Browser Sources subscribed to sessions on this channel should output audio
var is_browser_source_audio_enabled: bool:
	set(val):
		is_browser_source_audio_enabled = val;
		changed_data["is_browser_source_audio_enabled"] = is_browser_source_audio_enabled;
## This setting determines how the guests within a session should be laid out within the browser source. Can be one of the following values:       * `TILED_LAYOUT`: All live guests are tiled within the browser source with the same size. * `SCREENSHARE_LAYOUT`: All live guests are tiled within the browser source with the same size. If there is an active screen share, it is sized larger than the other guests.
var group_layout: String:
	set(val):
		group_layout = val;
		changed_data["group_layout"] = group_layout;
## View only token to generate browser source URLs
var browser_source_token: String:
	set(val):
		browser_source_token = val;
		changed_data["browser_source_token"] = browser_source_token;

var changed_data: Dictionary = {};

static func from_json(d: Dictionary) -> TwitchGetChannelGuestStarSettingsResponse:
	var result = TwitchGetChannelGuestStarSettingsResponse.new();
	if d.has("is_moderator_send_live_enabled") && d["is_moderator_send_live_enabled"] != null:
		result.is_moderator_send_live_enabled = d["is_moderator_send_live_enabled"];
	if d.has("slot_count") && d["slot_count"] != null:
		result.slot_count = d["slot_count"];
	if d.has("is_browser_source_audio_enabled") && d["is_browser_source_audio_enabled"] != null:
		result.is_browser_source_audio_enabled = d["is_browser_source_audio_enabled"];
	if d.has("group_layout") && d["group_layout"] != null:
		result.group_layout = d["group_layout"];
	if d.has("browser_source_token") && d["browser_source_token"] != null:
		result.browser_source_token = d["browser_source_token"];
	return result;

func to_dict() -> Dictionary:
	return changed_data;

func to_json() -> String:
	return JSON.stringify(to_dict());
