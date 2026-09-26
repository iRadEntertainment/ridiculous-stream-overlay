
extends Resource
class_name RSUser

enum WorkWith {
	UNASSIGNED,
	GODOT,
	UNITY,
	UNREAL,
	ART,
	PIXELART,
	ASEPRITE,
	KRITA,
	BLENDER,
	GAME_MAKER,
	OTHER_ENGINE,
	GAMING,
	CUSTOM_ENGINE,
}

# stats
var added_on: float # UNIX time
var global_interactions: Interactions
var last_applied_summary_id: String
var current_global_interactions: Interactions:
	get():
		if not global_interactions: return current_interactions
		if RS.summary_mng.summary and last_applied_summary_id == RS.summary_mng.summary.id:
			return global_interactions
		return global_interactions.merged_with_interactions(current_interactions)
var current_interactions: Interactions:
	get():
		return RS.summary_mng.get_user_current_interactions(user_id)

# twitch user
var username: String
var display_name: String
var user_id: int
var twitch_chat_color: Color
var profile_image_url: String
var broadcaster_type: String
var description: String
var offline_image_url: String

# promo
var is_streamer: bool
var auto_shoutout: bool
var auto_promotion: bool
var steam_app_ids: Dictionary[int, SteamAppData] # {int: SteamAppData} # TODO
var itchio_app_urls: Dictionary[String, ItchIOAppData] # {String: ItchIOAppData}
var work_with: WorkWith
var youtube_handle: String
var youtube_link: String:
	get: return "https://youtube.com".path_join(youtube_handle)
var bluesky_handle: String
var bluesky_link: String:
	get: return "https://bsky.app/profile/" + bluesky_handle.trim_prefix("@") + ".bsky.social"
var website: String
var shoutout_description: String
var promotion_description: String
var last_shout_unix_time: int

# customization
var custom_chat_color: Color
var custom_notification_sfx: String
var custom_action: String
var custom_beans_params: RSBeansParam



func to_dict() -> Dictionary:
	var d = {}
	d["added_on"] = added_on
	d["last_applied_summary_id"] = last_applied_summary_id
	if global_interactions:
		d["global_interactions"] = global_interactions.to_dict()
	
	d["username"] = username
	d["display_name"] = display_name
	d["user_id"] = user_id
	d["twitch_chat_color"] = twitch_chat_color.to_html()
	d["profile_image_url"] = profile_image_url
	d["broadcaster_type"] = broadcaster_type
	d["description"] = description
	d["offline_image_url"] = offline_image_url
	
	d["is_streamer"] = is_streamer
	d["auto_shoutout"] = auto_shoutout
	d["auto_promotion"] = auto_promotion
	d["steam_app_ids"] = {}
	for steam_app_id: int in steam_app_ids.keys():
		d["steam_app_ids"][str(steam_app_id)] = steam_app_ids[steam_app_id].to_json()
	d["itchio_app_urls"] = {}
	for itchio_app_url: String in itchio_app_urls.keys():
		d["itchio_app_urls"][itchio_app_url] = itchio_app_urls[itchio_app_url].to_json()
	d["work_with"] = int(work_with)
	d["youtube_handle"] = youtube_handle
	d["bluesky_handle"] = bluesky_handle
	d["website"] = website
	
	d["custom_chat_color"] = custom_chat_color.to_html()
	d["custom_notification_sfx"] = custom_notification_sfx
	d["custom_action"] = custom_action

	if custom_beans_params == null:
		d["custom_beans_params"] = null
	elif (custom_beans_params is RSBeansParam):
		d["custom_beans_params"] = custom_beans_params.to_dict()
	elif typeof(custom_beans_params) == TYPE_DICTIONARY:
		if custom_beans_params.is_empty():
			d["custom_beans_params"] = null
		else:
			if "scale" in custom_beans_params.keys():
				if typeof(custom_beans_params["scale"]) == TYPE_VECTOR2:
					custom_beans_params["scale"] = [custom_beans_params["scale"].x, custom_beans_params["scale"].y]
				d["custom_beans_params"] = custom_beans_params
			if "destroy_shard_params" in custom_beans_params.keys():
				var destroy_shard_params = custom_beans_params["destroy_shard_params"]
				if not destroy_shard_params:
					d["custom_beans_params"]["destroy_shard_params"] = null
				elif destroy_shard_params.is_empty():
					d["custom_beans_params"]["destroy_shard_params"] = null
				else:
					destroy_shard_params["destroy_shard_params"] = null
					if "scale" in destroy_shard_params.keys():
						if typeof(destroy_shard_params["scale"]) == TYPE_VECTOR2:
							destroy_shard_params["scale"] = [destroy_shard_params["scale"].x, destroy_shard_params["scale"].y]
					d["custom_beans_params"]["destroy_shard_params"] = destroy_shard_params

	d["shoutout_description"] = shoutout_description
	d["promotion_description"] = promotion_description
	d["last_shout_unix_time"] = last_shout_unix_time
	return d


func to_json() -> String:
	return JSON.stringify(to_dict())


func to_twitch_user() -> TwitchUser:
	var t_user = TwitchUser.from_json(to_dict())
	t_user.id = str(user_id)
	return t_user


func update_from_twitch_user(t_user: TwitchUser) -> void:
	if int(t_user.id) != user_id:
		push_warning("update_with_user: user ids are different")
		return
	username = t_user.login
	display_name = t_user.display_name
	profile_image_url = t_user.profile_image_url
	broadcaster_type = t_user.broadcaster_type
	description = t_user.description
	offline_image_url = t_user.offline_image_url


func update_with_user(updated_user: RSUser) -> void:
	if updated_user.user_id != user_id:
		push_warning("update_with_user: user ids are different")
		return
	
	# discard empty key:value pairs
	var current_user_dict: Dictionary = to_dict()
	var updated_user_dict: Dictionary = updated_user.to_dict()
	var validated_dict: Dictionary = {}
	for key in updated_user_dict.keys():
		var value = updated_user_dict[key]
		# skip booleans
		if typeof(value) == TYPE_BOOL:
			continue
		elif typeof(value) == TYPE_STRING:
			if value.is_empty(): continue
		elif typeof(value) == TYPE_INT:
			if value == 0: continue
		elif typeof(value) == TYPE_ARRAY:
			if value.is_empty(): continue
		validated_dict[key] = value
	
	update_from_dict(current_user_dict.merged(validated_dict, true))


func update_from_dict(d: Dictionary) -> void:
	added_on = d.get("added_on", Time.get_unix_time_from_system())
	last_applied_summary_id = d.get("last_applied_summary_id", "")
	global_interactions = Interactions.from_dict( d.get("global_interactions", {}) )
	
	username = d.get("username", "")
	display_name = d.get("display_name", "")
	user_id = d.get("user_id", -1)
	twitch_chat_color = Color.from_string(d.get("twitch_chat_color", ""), Color.WHITE)
	profile_image_url = d.get("profile_image_url", "")
	broadcaster_type = d.get("broadcaster_type", "")
	description = d.get("description", "")
	offline_image_url = d.get("offline_image_url", "")
	
	is_streamer = d.get("is_streamer", false)
	auto_shoutout = d.get("auto_shoutout", false)
	auto_promotion = d.get("auto_promotion", false)
	
	steam_app_ids = {}
	var steam_records: Variant = d.get("steam_app_ids", {})
	if steam_records is Dictionary:
		# JSON keys are strings; older in-memory snapshots use integers.
		for key in steam_records:
			if not str(key).is_valid_int() or int(key) <= 0:
				continue
			var record: Variant = steam_records[key]
			if not record is Dictionary or record.is_empty():
				continue
			var game := SteamAppData.from_json(record)
			game.steam_app_id = int(key)
			steam_app_ids[int(key)] = game
	
	itchio_app_urls = {}
	var itch_records: Variant = d.get("itchio_app_urls", {})
	if itch_records is Dictionary:
		for key in itch_records:
			var record: Variant = itch_records[key]
			if not key is String or key.is_empty() or not record is Dictionary or record.is_empty():
				continue
			itchio_app_urls[key] = ItchIOAppData.from_json(record)
	
	work_with = d.get("work_with", WorkWith.UNASSIGNED)
	youtube_handle = d.get("youtube_handle", "")
	bluesky_handle = d.get("bluesky_handle", "")
	website = d.get("website", "")
	
	custom_chat_color = Color.from_string(d.get("custom_chat_color", ""), Color.TRANSPARENT)
	custom_notification_sfx = d.get("custom_notification_sfx", "")
	custom_action = d.get("custom_action", "")
	if d.get("custom_beans_params") is Dictionary:
		custom_beans_params = RSBeansParam.from_json(d["custom_beans_params"])
	shoutout_description = d.get("shoutout_description", "")
	promotion_description = d.get("promotion_description", "")
	last_shout_unix_time = d.get("last_shout_unix_time", -1)


static func from_json(d: Dictionary) -> RSUser:
	var user := RSUser.new()
	user.update_from_dict(d)
	return user


static func from_twitcher_user(t_user: TwitchUser) -> RSUser:
	var user := RSUser.new()
	user.added_on = Time.get_unix_time_from_system()
	
	user.username = t_user.login
	user.user_id = int(t_user.id)
	user.display_name = t_user.display_name
	user.profile_image_url = t_user.profile_image_url
	user.broadcaster_type = t_user.broadcaster_type
	user.description = t_user.description
	user.offline_image_url = t_user.offline_image_url
	return user


class Interactions:
	enum SubTier {TIER1, TIER2, TIER3}
	var is_global := false
	var messages_count := 0
	var commands_count := 0
	var fake_commands_count := 0
	var channel_points_spent_count := 0
	var redeems: Dictionary[String, int] = {}
	var gigantify_count := 0
	var bits_count := 0
	var raids_in_count := 0
	var raid_viewers_count := 0
	var raids_out_count := 0
	# Self subscriptions, gifts sent, and resub announcements are distinct.
	var subscriptions: Dictionary[SubTier, int] = {}
	var gift_subscriptions: Dictionary[SubTier, int] = {}
	var resubscriptions: Dictionary[SubTier, int] = {}
	# Old records cannot distinguish a gift recipient from a self subscriber.
	var legacy_subscriptions: Dictionary[SubTier, int] = {}

	var redeems_count: int:
		get: return _sum(redeems)
	var subscriptions_count: int:
		get: return _sum(subscriptions)
	var gift_subscriptions_count: int:
		get: return _sum(gift_subscriptions)
	var resubscriptions_count: int:
		get: return _sum(resubscriptions)
	var legacy_subscriptions_count: int:
		get: return _sum(legacy_subscriptions)
	var messages_points: int:
		get: return messages_count * 3
	var commands_points: int:
		get: return commands_count * 2
	var fake_commands_points: int:
		get: return fake_commands_count
	var channel_points_spent_points: int:
		get: return int(channel_points_spent_count / 10.0)
	var gigantify_points: int:
		get: return gigantify_count * 100
	var bits_points: int:
		get: return bits_count * 4
	var raids_in_points: int:
		get: return raids_in_count * 100
	var subscription_points: int:
		get: return (subscriptions_count + gift_subscriptions_count) * 100
	var global_points: int:
		get:
			return messages_points + commands_points + fake_commands_points + channel_points_spent_points \
				+ gigantify_points + bits_points + raids_in_points + subscription_points

	const COUNTERS = ["messages_count", "commands_count", "fake_commands_count",
		"channel_points_spent_count", "gigantify_count", "bits_count", "raids_in_count",
		"raid_viewers_count", "raids_out_count"]
	const SUBSCRIPTION_FIELDS = ["subscriptions", "gift_subscriptions", "resubscriptions", "legacy_subscriptions"]

	static func _sum(values: Dictionary) -> int:
		var total := 0
		for value in values.values():
			total += int(value)
		return total

	static func tier_from_value(value: Variant) -> int:
		match str(value):
			"0", "1000": return SubTier.TIER1
			"1", "2000": return SubTier.TIER2
			"2", "3000": return SubTier.TIER3
		return -1

	func merge_current_interations(current: Interactions) -> void:
		if current == null:
			return
		for counter in COUNTERS:
			set(counter, int(get(counter)) + int(current.get(counter)))
		for field in ["redeems"] + SUBSCRIPTION_FIELDS:
			var target: Dictionary = get(field)
			var source: Dictionary = current.get(field)
			for key in source:
				target[key] = int(target.get(key, 0)) + int(source[key])

	func merged_with_interactions(other: Interactions) -> Interactions:
		var merged := Interactions.from_dict(to_dict())
		merged.merge_current_interations(other)
		return merged

	func to_dict() -> Dictionary:
		var data := {"version": 2, "is_global": is_global, "redeems": redeems.duplicate()}
		for counter in COUNTERS:
			data[counter] = get(counter)
		for field in SUBSCRIPTION_FIELDS:
			data[field] = {}
			var counts: Dictionary = get(field)
			for tier in counts:
				data[field][str(int(tier))] = counts[tier]
		return data

	static func from_dict(data: Dictionary) -> Interactions:
		var result := Interactions.new()
		result.is_global = bool(data.get("is_global", true))
		for counter in COUNTERS:
			result.set(counter, maxi(0, int(data.get(counter, 0))))
		if data.get("redeems") is Dictionary:
			for key in data.redeems:
				result.redeems[str(key)] = maxi(0, int(data.redeems[key]))
		for field in SUBSCRIPTION_FIELDS:
			var source: Variant = data.get(field, {})
			if not source is Dictionary:
				continue
			var target_field: String = field
			if field == "subscriptions" and int(data.get("version", 1)) < 2:
				target_field = "legacy_subscriptions"
			var target: Dictionary = result.get(target_field)
			for key in source:
				var tier := tier_from_value(key)
				if tier >= 0:
					target[tier] = int(target.get(tier, 0)) + maxi(0, int(source[key]))
		return result
