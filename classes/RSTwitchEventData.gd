extends RefCounted
class_name RSTwitchEventData

var type: String

var user_id: int
var username: String     # from twitch API username is "user_login"
var display_name: String # from twitch API display_name is "user_name"
var followed_at: String
var from_broadcaster_user_id: int
var from_broadcaster_username: String     # from twitch API username is "user_login"
var from_broadcaster_display_name: String # from twitch API display_name is "user_name"
var viewers: int
var user_input: String
var status: String
var reward_title: String
var reward_cost: int
var reward_prompt: String
var is_anonymous: bool
var message: String
var bits: int
var tier: int
var is_gift: bool
var total: int


static func _text(value: Variant) -> String:
	return "" if value == null else str(value)

static func _number(value: Variant) -> int:
	return 0 if value == null else int(value)

static func create_from_event_body(event_type: String, body: Dictionary) -> RSTwitchEventData:
	var data := RSTwitchEventData.new()
	data.type = event_type
	data.user_id = _number(body.get("user_id"))
	data.username = _text(body.get("user_login"))
	data.display_name = _text(body.get("user_name"))
	data.is_anonymous = bool(body.get("is_anonymous", false))
	match event_type:
		"channel.follow":
			data.followed_at = _text(body.get("followed_at"))
		"channel.channel_points_custom_reward_redemption.add":
			data.user_input = _text(body.get("user_input"))
			data.status = _text(body.get("status"))
			var reward: Dictionary = body.get("reward", {})
			data.reward_title = _text(reward.get("title"))
			data.reward_cost = _number(reward.get("cost"))
			data.reward_prompt = _text(reward.get("prompt"))
		"channel.raid":
			data.from_broadcaster_user_id = _number(body.get("from_broadcaster_user_id"))
			data.from_broadcaster_username = _text(body.get("from_broadcaster_user_login"))
			data.from_broadcaster_display_name = _text(body.get("from_broadcaster_user_name"))
			data.viewers = _number(body.get("viewers"))
		"channel.cheer":
			data.message = _text(body.get("message"))
			data.bits = _number(body.get("bits"))
		"channel.subscribe", "channel.subscription.gift", "channel.subscription.message":
			data.tier = _number(body.get("tier"))
			data.is_gift = bool(body.get("is_gift", false))
			data.total = _number(body.get("total"))
	return data
