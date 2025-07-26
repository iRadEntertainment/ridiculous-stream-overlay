@tool
extends Node
class_name RSTwitcher

static var _log: TwitchLogger = TwitchLogger.new(&"RSTwitcher")

var is_ready := false
var is_connected_to_twitch := false

@onready var service: TwitchService = %TwitchService
@onready var api: TwitchAPI = %TwitchAPI
@onready var auth: TwitchAuth = %TwitchAuth
@onready var irc: TwitchIRC = %TwitchIRC
@onready var eventsub: TwitchEventsub = %TwitchEventsub
@onready var media_loader: TwitchMediaLoader = %TwitchMediaLoader
@onready var twitch_chat: TwitchChat = %TwitchChat


# irc
signal received_chat_message(message: TwitchChatMessage)
signal first_session_message(message: TwitchChatMessage)
var first_session_message_list: Array[int] = []

# api
signal channel_points_redeemed(RSTwitchEventData)
signal followed(RSTwitchEventData)
signal raided(RSTwitchEventData)
signal subscribed(RSTwitchEventData)
signal cheered(RSTwitchEventData)

signal connected_to_twitch


func start():
	#---------------
	_log.i("Starting...")
	if !RS.settings.is_twitcher_setup():
		_log.w("Missing twitcher setup stuff. Abort setup")
		return
	#---------------
	#irc.received_privmsg.connect(_on_irc_received_privmsg)
	twitch_chat.message_received.connect(_on_chat_message_received)
	eventsub.event.connect(on_event)
	received_chat_message.connect(check_first_msg)
	first_session_message.connect(check_user_twitch_color)
	is_ready = true
	#if RS.settings.auto_connect:
		#
		#await connect_to_twitch()


func connect_to_twitch():
	apply_broadcaster_id(RS.settings.broadcaster_id)
	_log.i("Connecting...")
	is_connected_to_twitch = await service.setup()
	if is_connected_to_twitch:
		connected_to_twitch.emit()


func apply_broadcaster_id(broadcaster_id: String) -> void:
	_log.i("Applying Broadcaster ID to EventSub conditions: ID (%s)..." % broadcaster_id)
	for sub: TwitchEventsubConfig in eventsub._subscriptions:
		if sub.condition.has(&"broadcaster_user_id"):
			#_log.d("%s.broadcaster_user_id %s -> %s" %[TwitchEventsubDefinition.Type.keys()[sub.type] ,sub.condition.broadcaster_user_id, broadcaster_id])
			sub.condition[&"broadcaster_user_id"] = broadcaster_id
		if sub.condition.has(&"moderator_user_id"):
			#_log.d("%s.moderator_user_id %s -> %s" %[TwitchEventsubDefinition.Type.keys()[sub.type] ,sub.condition.moderator_user_id, broadcaster_id])
			sub.condition[&"moderator_user_id"] = broadcaster_id
		if sub.condition.has(&"to_broadcaster_user_id"):
			#_log.d("%s.to_broadcaster_user_id %s -> %s" %[TwitchEventsubDefinition.Type.keys()[sub.type] ,sub.condition.to_broadcaster_user_id, broadcaster_id])
			sub.condition[&"to_broadcaster_user_id"] = broadcaster_id


func add_command(
			command: String,
			callback: Callable,
			args_min: int = 0,
			args_max: int = -1,
			permission_level: TwitchCommand.PermissionFlag = TwitchCommand.PermissionFlag.EVERYONE,
			where: TwitchCommand.WhereFlag = TwitchCommand.WhereFlag.CHAT,
			user_cooldown: float = 0,
			global_cooldown: float = 0
		) -> TwitchCommand:
	return service.add_command(
		command,
		callback,
		args_min,
		args_max,
		permission_level,
		where,
		user_cooldown,
		global_cooldown,
	)


func get_user_by_id(user_id: String) -> TwitchUser: return await service.get_user_by_id(user_id)
func get_user(username: String) -> TwitchUser: return await service.get_user(username)


func get_user_color(user_id: int) -> Color:
	var res_col := await api.get_user_chat_color([str(user_id)])
	if res_col.data.is_empty():
		return Color.TRANSPARENT
	var data_col: TwitchUserChatColor = res_col.data.front()
	if !data_col.color.is_valid_html_color():
		return Color.TRANSPARENT
	return Color(data_col.color)


func get_team(team_name: String) -> TwitchTeam:
	var opt := TwitchGetTeams.Opt.new()
	opt.name = team_name
	var res: TwitchGetTeams.Response = await api.get_teams(opt)
	if res.data.is_empty():
		return null
	var team: TwitchTeam = res.data.front()
	return team


func get_teams_users(team_name: String) -> Array[TwitchUser]:
	var users: Array[RSUser] = []
	var user_ids: Array[String] = []
	
	var team: TwitchTeam = await get_team(team_name)
	if not team:
		return []
	
	for team_user: TwitchTeam.Users in team.users:
		user_ids.append(team_user.user_id)
	
	return await get_t_users(user_ids)


func get_t_users(user_ids: Array[String]) -> Array[TwitchUser]:
	var users: Array[TwitchUser] = []
	var opt := TwitchGetUsers.Opt.new()
	opt.id = user_ids
	var res: TwitchGetUsers.Response = await api.get_users(opt)
	for user_promise in res:
		var user: TwitchUser = await user_promise
		users.append(user)
	return users


#func _on_irc_received_privmsg(channel_name: String, username: String, message: String, tags: TwitchTags.PrivMsg):
	#received_chat_message.emit(channel_name, username, message, tags)


func _on_chat_message_received(t_message: TwitchChatMessage) -> void:
	received_chat_message.emit(t_message)


func chat(msg: String) -> void:
	twitch_chat.send_message(msg)


func whisper(_message: String, _username: String) -> void:
	_log.e("Whisper from bots aren't supported by Twitch anymore. See https://dev.twitch.tv/docs/irc/chat-commands/ at /w")


func announcement(msg: String, color := TwitchAnnouncementColor.PRIMARY):
	service.announcment(msg, color)


func remove_command(command: String) -> void:
	_log.i("Remove command %s" % command)
	service.remove_command(command)


func on_event(type: String, _data: Dictionary) -> void:
	var data := RSTwitchEventData.create_from_event_body(type, _data)
	match(type):
		"channel.follow": followed.emit(data)
		"channel.channel_points_custom_reward_redemption.add": channel_points_redeemed.emit(data)
		"channel.raid": raided.emit(data)
		"channel.cheer": cheered.emit(data)
		"channel.subscribe": subscribed.emit(data)


func gather_user_info_from_username(username: String) -> RSUser:
	var opt := TwitchGetUsers.Opt.new()
	opt.login = [str(username)]
	var response: TwitchGetUsers.Response = await api.get_users(opt)
	if response.data.is_empty():
		return null
	return RSUser.from_twitcher_user(response.data.front())


func gather_user_info_from_user_id(user_id: int) -> RSUser:
	var opt := TwitchGetUsers.Opt.new()
	opt.id = [str(user_id)]
	var response: TwitchGetUsers.Response = await api.get_users(opt)
	if response.data.is_empty():
		return null
	return RSUser.from_twitcher_user(response.data.front())


func get_live_streamers_data(user_ids: Array = []) -> Dictionary[int, TwitchStream]:
	if user_ids.is_empty():
		user_ids = RS.user_mng.get_known_streamers().keys()
	
	# cast int to String
	var user_ids_string: Array[String] = []
	for user_id: int in user_ids:
		user_ids_string.append(str(user_id))
	
	var streams_data: Dictionary[int, TwitchStream] = {}
	var opt := TwitchGetStreams.Opt.new()
	opt.type = "live"
	opt.user_id = user_ids_string
	var streams_iterator := await api.get_streams(opt)
	for stream_promise in streams_iterator:
		var stream_data: TwitchStream = await stream_promise
		if stream_data:
			streams_data[int(stream_data.user_id)] = stream_data
	
	return streams_data


func get_subscriptions() -> Dictionary[int, TwitchBroadcasterSubscription]:
	var results: Dictionary[int, TwitchBroadcasterSubscription] = {}
	var subscriptions_iterator := await api.get_broadcaster_subscriptions(
		TwitchGetBroadcasterSubscriptions.Opt.new(),
		RS.settings.broadcaster_id
	)
	_log.i("Fetching all subscribers...")
	for subscriber_promise in subscriptions_iterator:
		var subscriber_data: TwitchBroadcasterSubscription = await subscriber_promise
		if subscriber_data: # Always good to check
			results[int(subscriber_data.user_id)] = subscriber_data
	_log.i("Fetching subscribers finished.")
	return results


func check_first_msg(t_message: TwitchChatMessage) -> void:
	var user_id: int = int(t_message.chatter_user_id)
	if not user_id in first_session_message_list:
		first_session_message_list.append(user_id)
		first_session_message.emit(t_message)


func check_user_twitch_color(t_message: TwitchChatMessage) -> void:
	var color: String = t_message.color
	var user_id: int = int(t_message.chatter_user_id)
	if color.is_empty(): return
	if RS.user_mng.is_user_id_known(user_id):
		var user: RSUser = await RS.user_mng.get_user_from_user_id(user_id)
		if user.twitch_chat_color != Color(color):
			user.twitch_chat_color = Color(color)
			RSUserMng.save_user_to_json(user, RSSettings.get_users_path())


func raid(to_broadcaster_id: String) -> void:
	var opt := TwitchStartARaid.Opt.new()
	opt.from_broadcaster_id = RS.settings.broadcaster_id
	opt.to_broadcaster_id = to_broadcaster_id
	await api.start_a_raid(opt)


func get_follower_count() -> int:
	var opt = TwitchGetChannelFollowers.Opt.new()
	opt.first = str(100)
	var response := await api.get_channel_followers(opt, RS.settings.broadcaster_id)
	var count = response.data.size()
	
	while not response.pagination.cursor.is_empty():
		opt = TwitchGetChannelFollowers.Opt.new()
		opt.after = response.pagination.cursor
		response = await api.get_channel_followers(opt, RS.settings.broadcaster_id)
		count += response.data.size()
	return count


func get_moderators() -> Array[TwitchUserModerator]:
	var opt = TwitchGetModerators.Opt.new()
	opt.first = str(100)
	var response: TwitchGetModerators.Response = await api.get_moderators(opt, RS.settings.broadcaster_id)
	
	var total: Array[TwitchUserModerator] = []
	total.append_array(response.data)
	while not response.pagination.cursor.is_empty():
		opt = TwitchGetModerators.Opt.new()
		opt.after = response.pagination.cursor
		response = await api.get_moderators(opt, RS.settings.broadcaster_id)
		total.append_array(response.data)
	
	return total
