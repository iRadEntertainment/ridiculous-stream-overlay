extends Node
class_name RSSummaryMng

var summary_file_path: String:
	get(): return RS.settings.data_dir + "/stream_summary.json"
var summary: RSSummary

var l: TwitchLogger = TwitchLogger.new("RSSummaryMng")
var real_commands_list: Array[String]

signal user_interactions_updated(user_id: int)


#region Init
func _ready() -> void:
	l.enabled = true
	l.debug = true
	l.color = Color.HOT_PINK.to_html(false)


func start() -> void:
	load_summary()
	connect_twitcher_events()
	l.i("Started")


func connect_twitcher_events() -> void:
	RS.twitcher.received_chat_message.connect(_on_received_chat_message)
	RS.twitcher.channel_points_redeemed.connect(_on_channel_points_redeemed)
	# MISSING: gigantify_count # TODO
	RS.twitcher.cheered.connect(_on_cheered)
	RS.twitcher.raided.connect(_on_raided)
	RS.twitcher.subscribed.connect(_on_subscribed)
#endregion


#region Events
func _on_received_chat_message(
			_channel_name: String,
			_username: String,
			message: String,
			tags: TwitchTags.PrivMsg
		) -> void:
	var user_id: int = int(tags.user_id)
	if !RS.user_mng.is_user_id_known(user_id):
		return
	_add_interaction_from_chat(user_id, message)


func _on_channel_points_redeemed(event_data: RSTwitchEventData) -> void:
	if event_data.type != "channel.channel_points_custom_reward_redemption.add":
		return
	var user_id: int = int(event_data.user_id)
	if not RS.user_mng.is_user_id_known(user_id):
		return
	
	_init_interaction(user_id)
	var inter: RSUser.Interactions = summary.user_interactions[user_id]
	inter.channel_points_spent_count += event_data.reward_cost
	
	if inter.redeems.has(event_data.reward_title):
		inter.redeems[event_data.reward_title] += 1
	else:
		inter.redeems[event_data.reward_title] = 1
	user_interactions_updated.emit(user_id)


func _on_cheered(event_data: RSTwitchEventData) -> void:
	if event_data.type != "channel.cheer":
		return
	var user_id: int = int(event_data.user_id)
	if not RS.user_mng.is_user_id_known(user_id):
		return
	_init_interaction(user_id)
	var inter: RSUser.Interactions = summary.user_interactions[user_id]
	inter.bits_count += event_data.bits
	user_interactions_updated.emit(user_id)


func _on_raided(event_data: RSTwitchEventData) -> void:
	if event_data.type != "channel.raid":
		return
	var user_id: int = int(event_data.from_broadcaster_user_id)
	if not RS.user_mng.is_user_id_known(user_id):
		return
	_init_interaction(user_id)
	summary.user_interactions[user_id].raids_in_count += 1
	user_interactions_updated.emit(user_id)


func _on_subscribed(event_data: RSTwitchEventData) -> void:
	if event_data.type != "channel.subscribe":
		return
	var user_id: int = int(event_data.user_id)
	if not RS.user_mng.is_user_id_known(user_id):
		return
	_init_interaction(user_id)
	var inter: RSUser.Interactions = summary.user_interactions[user_id]
	
	if inter.subscriptions.has(event_data.tier):
		inter.subscriptions[event_data.tier] += 1
	else:
		inter.subscriptions[event_data.tier] = 1
	user_interactions_updated.emit(user_id)
#endregion


#region Save/Load
func start_new_summary() -> void:
	l.i("Starting new summary")
	summary = RSSummary.new()


func load_summary() -> void:
	if FileAccess.file_exists(summary_file_path):
		l.i("Loading summary from %s" % summary_file_path)
		var summary_data: Dictionary = RSUtl.load_json(summary_file_path)
		summary = RSSummary.from_json(summary_data)
	else:
		start_new_summary()


func save_summary() -> void:
	l.i("Saving summary file to %s" % summary_file_path)
	RSUtl.save_to_json(summary_file_path, summary.to_dict())


func delete_summary() -> void:
	l.i("Deleting summary")
	if FileAccess.file_exists(summary_file_path):
		OS.move_to_trash(summary_file_path)
	summary = null
#endregion


#region Utilities
func update_user_interactions(delete_file: bool = true) -> void:
	if not summary:
		l.e("Updating user interactions: Summary is null!")
		return
	
	l.i("Updating users with summary interactions")
	for user_id: int in summary.user_interactions:
		var user: RSUser = RS.user_mng.get_known_user_from_user_id(user_id)
		if not user.global_interactions:
			user.global_interactions = RSUser.Interactions.new()
		
		var current_interactions: RSUser.Interactions = summary.user_interactions[user_id]
		user.global_interactions.merge_current_interations(current_interactions)
	
	if delete_file:
		delete_summary()


func has_current_user(user_id: int) -> bool:
	if not summary: return false
	return summary.user_interactions.has(user_id)


func get_user_current_interactions(user_id: int) -> RSUser.Interactions:
	return summary.user_interactions.get(user_id, null)
#endregion


#region Utilities Private
func _init_interaction(user_id: int) -> void:
	if not has_current_user(user_id):
		summary.user_interactions[user_id] = RSUser.Interactions.new()
		summary.user_interactions[user_id].is_global = false


func _add_interaction_from_chat(user_id: int, message: String) -> void:
	_init_interaction(user_id)
	var inter: RSUser.Interactions = summary.user_interactions[user_id]
	if message.begins_with("!"):
		message = message.lstrip("!")
		if message in RS.twitcher.commands.commands.keys():
			inter.commands_count += 1
		else:
			inter.fake_commands_count += 1
	else:
		inter.messages_count += 1
	user_interactions_updated.emit(user_id)


func _notification(what: int) -> void:
	const catch: Array = [
		NOTIFICATION_CRASH,
		NOTIFICATION_WM_CLOSE_REQUEST,
	]
	if what in catch:
		save_summary()
#endregion


class RSSummary:
	var stream_start: int # UNIX time
	var user_interactions: Dictionary[int, RSUser.Interactions] = {} # {user_id, count}
	
	func to_dict() -> Dictionary:
		var data: Dictionary = {}
		data["stream_start"] = stream_start
		data["user_interactions"] = {}
		for user_id: int in user_interactions:
			data["user_interactions"][user_id] = user_interactions[user_id].to_dict()
		return data
	
	
	static func from_json(data: Dictionary) -> RSSummary:
		var new_summary: RSSummary = RSSummary.new()
		new_summary.stream_start = data.get("stream_start", Time.get_unix_time_from_system())
		new_summary.user_interactions = {}
		for user_id_s: String in data.get("user_interactions", {}):
			var user_id: int = int(user_id_s)
			var interactions_data: Dictionary = data.get("user_interactions")[user_id_s]
			var interactions: RSUser.Interactions = RSUser.Interactions.from_dict(interactions_data)
			new_summary.user_interactions[user_id] = interactions
		return new_summary
