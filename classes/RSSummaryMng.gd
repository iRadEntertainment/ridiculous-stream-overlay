extends Node
class_name RSSummaryMng

const AUTOSAVE_SECONDS := 600.0
var current_summary_file_path: String:
	get: return RSSettings.get_summaries_path().path_join("stream_summary.json")
var stored_summary_file_path: String:
	get: return RSSettings.get_summaries_path().path_join("stream_summary_%s.json")
var _tmr_autosave: Timer
var summary: RSSummary
var _started := false
static var _log: TwitchLogger = TwitchLogger.new(&"RSSummaryMng")

signal user_interactions_updated(user_id: int)
signal summary_changed

func _ready() -> void:
	_tmr_autosave = Timer.new()
	_tmr_autosave.wait_time = AUTOSAVE_SECONDS
	_tmr_autosave.timeout.connect(save_current_summary)
	add_child(_tmr_autosave)

func start() -> void:
	if _started:
		return
	_started = true
	load_summary()
	connect_twitcher_events()
	_tmr_autosave.start()

func connect_twitcher_events() -> void:
	var connections := {
		RS.twitcher.received_chat_message: _on_received_chat_message,
		RS.twitcher.channel_points_redeemed: _on_channel_points_redeemed,
		RS.twitcher.cheered: _on_cheered,
		RS.twitcher.raided: _on_raided,
		RS.twitcher.subscribed: _on_subscribed,
		RS.twitcher.subscriptions_gifted: _on_subscriptions_gifted,
		RS.twitcher.resubscribed: _on_resubscribed,
	}
	for event: Signal in connections:
		if not event.is_connected(connections[event]):
			event.connect(connections[event])

func _can_record() -> bool:
	return summary != null and summary.stream_stopped == 0

func _interaction(user_id: int, login: String, display_name: String, color: String = "") -> RSUser.Interactions:
	if not _can_record() or user_id <= 0:
		return null
	var user: RSUser = RS.user_mng.observe_user(user_id, login, display_name, color)
	summary.participants[user_id] = {
		"username": user.username, "display_name": user.display_name,
		"color": user.twitch_chat_color.to_html(),
	}
	if not summary.user_interactions.has(user_id):
		summary.user_interactions[user_id] = RSUser.Interactions.new()
	return summary.user_interactions[user_id]

func _updated(user_id: int) -> void:
	user_interactions_updated.emit(user_id)
	summary_changed.emit()

func _on_received_chat_message(message: TwitchChatMessage) -> void:
	var user_id := int(message.chatter_user_id)
	var inter := _interaction(user_id, message.chatter_user_login, message.chatter_user_name, message.color)
	if inter == null or message.message == null:
		return
	var text := message.message.text
	if text.begins_with("!"):
		if _is_command(text):
			inter.commands_count += 1
		else:
			inter.fake_commands_count += 1
	else:
		inter.messages_count += 1
	# Bits are recorded exclusively from channel.cheer, not its chat copy.
	if message.message_type == TwitchChatMessage.MessageType.power_ups_gigantified_emote:
		inter.gigantify_count += 1
	_updated(user_id)

func _on_channel_points_redeemed(data: RSTwitchEventData) -> void:
	if data.type != "channel.channel_points_custom_reward_redemption.add":
		return
	var inter := _interaction(data.user_id, data.username, data.display_name)
	if inter == null:
		return
	inter.channel_points_spent_count += maxi(0, data.reward_cost)
	inter.redeems[data.reward_title] = inter.redeems.get(data.reward_title, 0) + 1
	_updated(data.user_id)

func _on_cheered(data: RSTwitchEventData) -> void:
	if data.type != "channel.cheer" or not _can_record():
		return
	if data.is_anonymous:
		summary.anonymous_bits += maxi(0, data.bits)
		summary_changed.emit()
		return
	var inter := _interaction(data.user_id, data.username, data.display_name)
	if inter != null:
		inter.bits_count += maxi(0, data.bits)
		_updated(data.user_id)

func _on_raided(data: RSTwitchEventData) -> void:
	if data.type != "channel.raid":
		return
	var inter := _interaction(data.from_broadcaster_user_id, data.from_broadcaster_username, data.from_broadcaster_display_name)
	if inter != null:
		inter.raids_in_count += 1
		inter.raid_viewers_count += maxi(0, data.viewers)
		_updated(data.from_broadcaster_user_id)

func _on_subscribed(data: RSTwitchEventData) -> void:
	if data.type != "channel.subscribe" or data.is_gift:
		return
	_record_subscription(data, "subscriptions", 1)

func _on_subscriptions_gifted(data: RSTwitchEventData) -> void:
	if data.type != "channel.subscription.gift" or not _can_record():
		return
	var tier := RSUser.Interactions.tier_from_value(data.tier)
	if tier < 0 or data.total <= 0:
		return
	if data.is_anonymous:
		summary.anonymous_gift_subscriptions[tier] = summary.anonymous_gift_subscriptions.get(tier, 0) + data.total
		summary_changed.emit()
	else:
		_record_subscription(data, "gift_subscriptions", data.total)

func _on_resubscribed(data: RSTwitchEventData) -> void:
	if data.type == "channel.subscription.message":
		# An announcement is not evidence of a new purchase or payment quantity.
		_record_subscription(data, "resubscriptions", 1)

func _record_subscription(data: RSTwitchEventData, field: String, count: int) -> void:
	var tier := RSUser.Interactions.tier_from_value(data.tier)
	if tier < 0:
		return
	var inter := _interaction(data.user_id, data.username, data.display_name)
	if inter == null:
		return
	var counts: Dictionary = inter.get(field)
	counts[tier] = int(counts.get(tier, 0)) + count
	_updated(data.user_id)

func start_new_summary() -> bool:
	var previous := summary
	if previous != null:
		if previous.stream_stopped == 0:
			previous.stream_stopped = int(Time.get_unix_time_from_system())
		# Persist the closed session before updating lifetime totals. Its ID lets
		# a retry after a crash skip users whose totals were already saved.
		if not save_current_summary() or not save_stored_summary() or not update_user_interactions():
			_log.e("Summary rollover incomplete; retry starting a new summary to finish saving.")
			summary_changed.emit()
			return false
	summary = RSSummary.new()
	if not save_current_summary():
		summary = previous
		return false
	summary_changed.emit()
	return true

func load_summary() -> void:
	if FileAccess.file_exists(current_summary_file_path):
		var data: Variant = RSUtl.load_json(current_summary_file_path)
		if data is Dictionary:
			summary = RSSummary.from_json(data)
			if summary.stream_stopped > 0:
				start_new_summary() # Finish an interrupted rollover.
			return
		# Preserve malformed input before writing a replacement.
		var backup := current_summary_file_path + ".invalid-%d" % Time.get_unix_time_from_system()
		if DirAccess.copy_absolute(current_summary_file_path, backup) != OK:
			_log.e("Could not back up malformed summary; leaving it untouched.")
			return
	start_new_summary()

func save_current_summary() -> bool:
	if summary == null:
		return false
	summary.last_saved_at = int(Time.get_unix_time_from_system())
	return RSUtl.save_to_json(current_summary_file_path, summary.to_dict())

func save_stored_summary() -> bool:
	if summary == null:
		return false
	# Include the ID so two resets in the same second cannot overwrite an archive.
	var suffix := RSUtl.unix_to_string_filepath(summary.stream_start, true) + "_" + summary.id
	return RSUtl.save_to_json(stored_summary_file_path % suffix, summary.to_dict())

func update_user_interactions() -> bool:
	if summary == null:
		return false
	for user_id: int in summary.user_interactions:
		var user: RSUser = RS.user_mng.get_known_user_from_user_id(user_id)
		if user == null or user.last_applied_summary_id == summary.id:
			continue
		var previous: RSUser.Interactions = user.global_interactions
		var previous_id: String = user.last_applied_summary_id
		var totals := RSUser.Interactions.new() if previous == null else RSUser.Interactions.from_dict(previous.to_dict())
		totals.merge_current_interations(summary.user_interactions[user_id])
		totals.is_global = true
		user.global_interactions = totals
		user.last_applied_summary_id = summary.id
		if not RS.user_mng.save_user(user):
			user.global_interactions = previous
			user.last_applied_summary_id = previous_id
			return false
	return true

func has_current_user(user_id: int) -> bool:
	return summary != null and summary.user_interactions.has(user_id)

func get_user_current_interactions(user_id: int) -> RSUser.Interactions:
	return summary.user_interactions.get(user_id) if summary != null else null

func _is_command(message: String) -> bool:
	var words := message.trim_prefix("!").strip_edges().split(" ", false)
	if words.is_empty():
		return false
	for command: TwitchCommand in TwitchCommand.ALL_COMMANDS:
		if command.command.to_lower() == words[0].to_lower():
			return true
	return false

func _notification(what: int) -> void:
	if what in [NOTIFICATION_CRASH, NOTIFICATION_WM_CLOSE_REQUEST]:
		save_current_summary()

class RSSummary:
	const VERSION := 2
	var id: String = Crypto.new().generate_random_bytes(16).hex_encode()
	var stream_start: int = int(Time.get_unix_time_from_system())
	var stream_stopped := 0
	var last_saved_at := 0
	var participants: Dictionary[int, Dictionary] = {}
	var user_interactions: Dictionary[int, RSUser.Interactions] = {}
	var anonymous_bits := 0
	var anonymous_gift_subscriptions: Dictionary[int, int] = {}

	func to_dict() -> Dictionary:
		var data := {"version": VERSION, "id": id, "stream_start": stream_start,
			"stream_stopped": stream_stopped, "last_saved_at": last_saved_at,
			"participants": {}, "user_interactions": {}, "anonymous_bits": anonymous_bits,
			"anonymous_gift_subscriptions": {}}
		for user_id in participants:
			data.participants[str(user_id)] = participants[user_id].duplicate()
		for user_id in user_interactions:
			data.user_interactions[str(user_id)] = user_interactions[user_id].to_dict()
		for tier in anonymous_gift_subscriptions:
			data.anonymous_gift_subscriptions[str(tier)] = anonymous_gift_subscriptions[tier]
		return data

	func get_identity(user_id: int) -> Dictionary:
		if participants.has(user_id):
			return participants[user_id]
		var user: RSUser = RS.user_mng.get_cached_user(user_id)
		if user != null:
			return {"username": user.username, "display_name": user.display_name, "color": user.twitch_chat_color.to_html()}
		return {"username": "", "display_name": "User %d" % user_id, "color": "ffffff"}

	func get_chatters_user_ids() -> Array[int]:
		var ids: Array[int] = []
		for user_id in user_interactions:
			var inter := user_interactions[user_id]
			if inter.messages_count + inter.commands_count + inter.fake_commands_count > 0:
				ids.append(user_id)
		return ids

	func _ids_with(counter: String) -> Array[int]:
		var ids: Array[int] = []
		for user_id in user_interactions:
			if int(user_interactions[user_id].get(counter)) > 0:
				ids.append(user_id)
		return ids

	func get_cheerers_user_ids() -> Array[int]:
		return _ids_with("bits_count")
	func get_subscribers_user_ids() -> Array[int]:
		return _ids_with("subscriptions_count")
	func get_gifters_user_ids() -> Array[int]:
		return _ids_with("gift_subscriptions_count")
	func get_resubscribers_user_ids() -> Array[int]:
		return _ids_with("resubscriptions_count")
	func get_legacy_subscribers_user_ids() -> Array[int]:
		return _ids_with("legacy_subscriptions_count")
	func get_raiders_user_ids() -> Array[int]:
		return _ids_with("raids_in_count")

	func elapsed_seconds(now: int = -1) -> int:
		if now < 0:
			now = int(Time.get_unix_time_from_system())
		return maxi(0, (stream_stopped if stream_stopped > 0 else now) - stream_start)

	static func from_json(data: Dictionary) -> RSSummary:
		var result := RSSummary.new()
		result.stream_start = int(data.get("stream_start", result.stream_start))
		result.id = str(data.get("id", "legacy-%d" % result.stream_start))
		result.last_saved_at = int(data.get("last_saved_at", data.get("stream_stopped", 0)))
		# Older saves used stream_stopped for autosave time, not session completion.
		if int(data.get("version", 1)) >= VERSION:
			result.stream_stopped = int(data.get("stream_stopped", 0))
		var records: Variant = data.get("user_interactions", {})
		if records is Dictionary:
			for key in records:
				var user_id := int(key)
				if user_id > 0 and records[key] is Dictionary:
					result.user_interactions[user_id] = RSUser.Interactions.from_dict(records[key])
		var identities: Variant = data.get("participants", {})
		if identities is Dictionary:
			for key in identities:
				if int(key) > 0 and identities[key] is Dictionary:
					result.participants[int(key)] = identities[key].duplicate()
		result.anonymous_bits = maxi(0, int(data.get("anonymous_bits", 0)))
		var gifts: Variant = data.get("anonymous_gift_subscriptions", {})
		if gifts is Dictionary:
			for key in gifts:
				var tier := RSUser.Interactions.tier_from_value(key)
				if tier >= 0:
					result.anonymous_gift_subscriptions[tier] = maxi(0, int(gifts[key]))
		return result
