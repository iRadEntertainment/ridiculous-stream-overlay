
extends Resource
class_name RSUser

enum WorkWith {UNASSIGNED, GODOT, UNITY, UNREAL, ART, PIXELART, ASEPRITE, KRITA}

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
var steam_app_ids: Array[int]
var itchio_app_urls: Array[String]
var work_with: WorkWith
var youtube_handle: String
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
	d["steam_app_ids"] = steam_app_ids
	d["itchio_app_urls"] = itchio_app_urls
		
	d["work_with"] = int(work_with)
	d["youtube_handle"] = youtube_handle
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
	username = d.get("username", "")
	display_name = d.get("display_name", "")
	user_id = d.get("user_id", -1)
	twitch_chat_color = Color.from_string(d["twitch_chat_color"], Color.BLACK)
	profile_image_url = d.get("profile_image_url", "")
	broadcaster_type = d.get("broadcaster_type", "")
	description = d.get("description", "")
	offline_image_url = d.get("offline_image_url", "")
	
	is_streamer = d.get("is_streamer", false)
	auto_shoutout = d.get("auto_shoutout", false)
	auto_promotion = d.get("auto_promotion", false)
	steam_app_ids = []
	for steam_id in d.get("steam_app_ids", []):
		steam_id = int(steam_id)
		steam_app_ids.append(steam_id)
	itchio_app_urls = []
	if d.get("itchio_app_urls", []) != null:
		for itchio_url: String in d.get("itchio_app_urls", []):
			itchio_app_urls.append(itchio_url)
	work_with = d.get("work_with", WorkWith.UNASSIGNED)
	youtube_handle = d.get("youtube_handle", "")
	website = d.get("website", "")
	
	custom_chat_color = Color.from_string(d["custom_chat_color"], Color.BLACK)
	custom_notification_sfx = d.get("custom_notification_sfx", "")
	custom_action = d.get("custom_action", "")
	if d["custom_beans_params"] != null:
		custom_beans_params = RSBeansParam.from_json(d["custom_beans_params"])
	shoutout_description = d.get("shoutout_description", null)
	promotion_description = d.get("promotion_description", null)
	last_shout_unix_time = d.get("last_shout_unix_time", -1)


static func from_json(d: Dictionary) -> RSUser:
	var user := RSUser.new()
	user.update_from_dict(d)
	return user


static func from_twitcher_user(t_user: TwitchUser) -> RSUser:
	var user := RSUser.new()
	user.username = t_user.login
	user.user_id = int(t_user.id)
	user.display_name = t_user.display_name
	user.profile_image_url = t_user.profile_image_url
	user.broadcaster_type = t_user.broadcaster_type
	user.description = t_user.description
	user.offline_image_url = t_user.offline_image_url
	return user
