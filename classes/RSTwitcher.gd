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

# irc
signal received_chat_message(channel_name: String, username: String, message: String, tags: TwitchTags.PrivMsg)
signal first_session_message(username: String, message: String, tags: TwitchTags.PrivMsg)
var first_session_message_username_list: PackedStringArray = []

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
	#eventsub.event.connect(on_event)
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
		if sub.condition.has("broadcaster_user_id"):
			_log.d("%s.broadcaster_user_id %s -> %s" %[TwitchEventsubDefinition.Type.keys()[sub.type] ,sub.condition.broadcaster_user_id, broadcaster_id])
			sub.condition.broadcaster_user_id = broadcaster_id
		if sub.condition.has("moderator_user_id"):
			_log.d("%s.moderator_user_id %s -> %s" %[TwitchEventsubDefinition.Type.keys()[sub.type] ,sub.condition.moderator_user_id, broadcaster_id])
			sub.condition.broadcaster_user_id = broadcaster_id
		if sub.condition.has("to_broadcaster_user_id"):
			_log.d("%s.to_broadcaster_user_id %s -> %s" %[TwitchEventsubDefinition.Type.keys()[sub.type] ,sub.condition.to_broadcaster_user_id, broadcaster_id])
			sub.condition.broadcaster_user_id = broadcaster_id


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

#func get_teams_users(team_name: String) -> PackedStringArray:
	#var usernames := PackedStringArray()
	#if not is_connected_to_twitch:
		#return usernames
	##var res := await api.get_teams("indiegamedevs", "") <- this is specific for this team
	#var res := await api.get_teams(team_name, "")
	#if res.data.is_empty():
		#return usernames
	
	#for user: TwitchTeam.Users in res.data[0].users:
		#usernames.append(user.user_name)
	#return usernames
	

#func get_teams_users_online(team_name: String) -> PackedStringArray:
	#var usernames = await get_teams_users(team_name)
	#return await get_users_online(usernames)


#func get_users_online(users: PackedStringArray) -> PackedStringArray:
	#var online := PackedStringArray()
	#if not is_connected_to_twitch: return online
	#var max_user_query = 30
	#while not users.is_empty():
		#var batch: Array[String] = []
		#var count = 0
		#for i in range(users.size()-1, -1, -1):
			#var username = users[i]
			#users.remove_at(i)
			#batch.append(username)
			#if count > max_user_query:
				#var res := await api.get_streams([], batch, [], "live", [], 1, "", "")
				#for stream: TwitchStream in res.data:
					#online.append(stream.user_login)
				#break
			#count += 1
	#return online

func _on_irc_received_privmsg(channel_name: String, username: String, message: String, tags: TwitchTags.PrivMsg):
	received_chat_message.emit(channel_name, username, message, tags)

#func chat(msg: String, channel_name := ""):
	#if (not channel_name is String) or channel_name.strip_edges().is_empty():
		#if !RS.settings.chatbot_channels.is_empty():
			#irc.chat(msg, RS.settings.chatbot_channels.front());
	#else:
		#irc.chat(msg, channel_name);

func whisper(_message: String, _username: String) -> void:
	_log.e("Whisper from bots aren't supported by Twitch anymore. See https://dev.twitch.tv/docs/irc/chat-commands/ at /w")

## Possible colors are: * blue * green * orange * purple * primary (default)
#func announcement(msg: String, color := ""):
	#var body := TwitchSendChatAnnouncementBody.new()
	#body.message = msg
	#body.color = color
	#var path = "/helix/chat/announcements?"
	#path += "broadcaster_id=" + str(RS.settings.broadcaster_id) + "&"
	#path += "moderator_id=" + str(RS.settings.broadcaster_id)
	#await api.request(path, HTTPClient.METHOD_POST, body, "application/json")


#func remove_command(command: String) -> void:
	#_log.i("Remove command %s" % command)
	#commands.remove_command(command);

func on_event(type: String, _data: Dictionary) -> void:
	var data := RSTwitchEventData.create_from_event_body(type, _data)
	match(type):
		"channel.follow": followed.emit(data)
		"channel.channel_points_custom_reward_redemption.add": channel_points_redeemed.emit(data)
		"channel.raid": raided.emit(data)
		"channel.cheer": cheered.emit(data)
		"channel.subscribe": subscribed.emit(data)


#func gather_user_info_from_username(username: String) -> RSUser:
	#var response: TwitchGetUsersResponse = await api.get_users([], [username])
	#return gather_user_info_from_response(response)


#func gather_user_info_from_user_id(user_id: int) -> RSUser:
	#var response: TwitchGetUsersResponse = await api.get_users([str(user_id)], [])
	#return gather_user_info_from_response(response)


#func gather_user_info_from_response(response: TwitchGetUsersResponse) -> RSUser:
	#if response.data.is_empty():
		#return
	#
	#var user = RSUser.new()
	#user.user_id = response.data[0]["id"]
	#user.display_name = response.data[0]["display_name"]
	#user.username = response.data[0]["login"]
	#user.profile_image_url = response.data[0]["profile_image_url"]
	#return user


#func get_live_streamers_data(user_names_or_ids: Array = []) -> Dictionary:
	#if not is_connected_to_twitch:
		#return {}
#
	#if user_names_or_ids.is_empty():
		#for user: RSUser in RS.user_mng.known.values():
			#if user.get("is_streamer") != null:
				#if user.is_streamer:
					#user_names_or_ids.append(user.username)
	#
	#var live_streamers_data := {}
	#var max_user_query = 20
	#while not user_names_or_ids.is_empty():
		#var names: Array[String] = []
		#var ids: Array[String] = []
		#var count = 0
		#for i in range(user_names_or_ids.size()-1, -1, -1):
			#var user_name_id = user_names_or_ids[i]
			#user_names_or_ids.remove_at(i)
			#if user_name_id is String:
				#names.append(user_name_id)
			#elif user_name_id is int:
				#ids.append(str(user_name_id))
			#
			#if count > max_user_query:
				#var res := await api.get_streams(ids, names, [], "live", [], 1, "", "")
				#for stream: TwitchStream in res.data:
					#live_streamers_data[int(stream.user_id)] = stream
				#break
			#count += 1
	#
	#return live_streamers_data


func check_first_msg(_channel_name: String, username: String, message: String, tags: TwitchTags.PrivMsg):
	if not username in first_session_message_username_list:
		first_session_message_username_list.append(username)
		first_session_message.emit(username, message, tags)


func check_user_twitch_color(username: String, _message: String, tags: TwitchTags.PrivMsg) -> void:
	if tags.color.is_empty(): return
	if RS.user_mng.is_username_known(username):
		var user: RSUser = await RS.user_mng.get_user_from_username(username)
		if user.twitch_chat_color != Color(tags.color):
			user.twitch_chat_color = Color(tags.color)
			RSUserMng.save_user_to_json(user, RSSettings.get_users_path())

#func raid(to_broadcaster_id: String):
	#var path = "/helix/raids?from_broadcaster_id={from}&to_broadcaster_id={to}".format(
		#{"from": str(RS.settings.broadcaster_id),
		#"to":to_broadcaster_id})
	#await api.request(path, HTTPClient.METHOD_POST, "", "application/x-www-form-urlencoded");

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
