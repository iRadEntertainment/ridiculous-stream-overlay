extends Node
class_name RSTwitcher


var irc : TwitchIRC
var api : TwitchRestAPI
var eventsub: TwitchEventsub
var commands: TwitchCommandHandler
var l: RSLogger
var auth: TwitchAuth
var icon_loader: TwitchIconLoader
var eventsub_debug: TwitchEventsub
var cheer_repository: TwitchCheerRepository


var is_ready := false
var is_connected_to_twitch := false

# irc
signal received_chat_message(channel_name: String, username: String, message: String, tags: TwitchTags.PrivMsg)
signal first_session_message(username: String, tags: TwitchTags.PrivMsg)
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
	l = RSLogger.new(RSSettings.LOGGER_NAME_SERVICE)
	l.i("Starting...")
	if !RS.settings.is_twitcher_setup():
		return

	auth = await TwitchAuth.new()
	api = TwitchRestAPI.new(auth)
	icon_loader = TwitchIconLoader.new(api)
	eventsub = TwitchEventsub.new(api)
	eventsub_debug = TwitchEventsub.new(api, false)
	irc = TwitchIRC.new(auth)
	
	#gif_importer_imagemagick = GifImporterImagemagick.new()
	#gif_importer_native = GifImporterNative.new()
	commands = TwitchCommandHandler.new()
	#---------------
	irc.received_privmsg.connect(_on_irc_received_privmsg)
	eventsub.event.connect(on_event)
	received_chat_message.connect(check_first_msg)
	first_session_message.connect(check_user_twitch_color)
	is_ready = true
	if RS.settings.auto_connect:
		await connect_to_twitch()


func connect_to_twitch():
	l.i("Connecting...")
	await auth.ensure_authentication()
	l.i("Auth ensured.")
	await _init_chat()
	l.i("Chat initialized.")
	_init_eventsub()
	if RS.settings.use_test_server:
		eventsub_debug.connect_to_eventsub(RS.settings.eventsub_test_server_url)
	_init_cheermotes()
	l.i("Initialized and ready")
	
	is_connected_to_twitch = true
	connected_to_twitch.emit()


func _init_chat() -> void:
	irc.received_privmsg.connect(commands.handle_chat_command);
	irc.received_whisper.connect(commands.handle_whisper_command);
	irc.connect_to_irc();
	if !RS.settings.chatbot_channels.is_empty():
		irc.join_channel(RS.settings.chatbot_channels.front())
	icon_loader.do_preload();
	await icon_loader.preload_done;

func _init_eventsub() -> void:
	eventsub.connect_to_eventsub(RS.settings.eventsub_live_server_url)
	if !eventsub.event.is_connected(on_event):
		eventsub.event.connect(on_event)

## Get data about a user by USER_ID see get_user for by username
func get_user_by_id(user_id: String) -> TwitchUser:
	if !api: return null
	var user_data : TwitchGetUsersResponse = await api.get_users([user_id], []);
	if user_data.data.is_empty(): return null;
	return user_data.data[0];

## Get data about a user by USERNAME see get_user_by_id for by user_id
func get_user(username: String) -> TwitchUser:
	if !api: return null
	var res : TwitchGetUsersResponse = await api.get_users([], [username])
	if res.data.is_empty():
		return null
	var t_user : TwitchUser = res.data[0]
	return t_user

func get_user_color(user_id: int) -> Color:
	var res_col := await api.get_user_chat_color([str(user_id)])
	if res_col.data.is_empty():
		return Color.BLACK
	var data_col : TwitchUserChatColor = res_col.data[0]
	if !data_col.color.is_valid_html_color():
		return Color.BLACK
	return Color(data_col.color)

func get_teams_users(team_name: String) -> PackedStringArray:
	var usernames := PackedStringArray()
	if not is_connected_to_twitch:
		return usernames
	#var res := await api.get_teams("indiegamedevs", "") <- this is specific for this team
	var res := await api.get_teams(team_name, "")
	if res.data.is_empty():
		return usernames
	
	for user: TwitchTeam.Users in res.data[0].users:
		usernames.append(user.user_name)
	return usernames
	

func get_teams_users_online(team_name: String) -> PackedStringArray:
	var usernames = await get_teams_users(team_name)
	return await get_users_online(usernames)


func get_users_online(users: PackedStringArray) -> PackedStringArray:
	var online := PackedStringArray()
	if not is_connected_to_twitch: return online
	var max_user_query = 30
	while not users.is_empty():
		var batch : Array[String] = []
		var count = 0
		for i in range(users.size()-1, -1, -1):
			var username = users[i]
			users.remove_at(i)
			batch.append(username)
			if count > max_user_query:
				var res := await api.get_streams([], batch, [], "live", [], 1, "", "")
				for stream : TwitchStream in res.data:
					online.append(stream.user_login)
				break
			count += 1
	return online

## Refer to https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/ for details on
## which API versions are available and which conditions are required.
func subscribe_event(event_name : String, version : String, conditions : Dictionary, session_id: String):
	eventsub.subscribe_event(event_name, version, conditions, session_id)

## Waits for connection to eventsub. Eventsub is ready to subscribe events.
func wait_for_connection() -> void:
	await eventsub.wait_for_connection();

func _on_irc_received_privmsg(channel_name: String, username: String, message: String, tags: TwitchTags.PrivMsg):
	received_chat_message.emit(channel_name, username, message, tags)

func chat(msg : String, channel_name := ""):
	if (not channel_name is String) or channel_name.strip_edges().is_empty():
		if !RS.settings.chatbot_channels.is_empty():
			irc.chat(msg, RS.settings.chatbot_channels.front());
	else:
		irc.chat(msg, channel_name);

func whisper(_message: String, _username: String) -> void:
	l.e("Whipser from bots aren't supported by Twitch anymore. See https://dev.twitch.tv/docs/irc/chat-commands/ at /w")

## Possible colors are: * blue * green * orange * purple * primary (default)
func announcement(msg : String, color := ""):
	var body := TwitchSendChatAnnouncementBody.new()
	body.message = msg
	body.color = color
	var path = "/helix/chat/announcements?"
	path += "broadcaster_id=" + str(RS.settings.broadcaster_id) + "&"
	path += "moderator_id=" + str(RS.settings.broadcaster_id)
	await api.request(path, HTTPClient.METHOD_POST, body, "application/json")

## Returns the definition of emotes for given channel or for the global emotes.
## Key: EmoteID as String ; Value: TwitchGlobalEmote | TwitchChannelEmote
func get_emotes_data(channel_id: String = "global") -> Dictionary:
	return await icon_loader.get_cached_emotes(channel_id);

## Returns the definition of badges for given channel or for the global bages.
## Key: category / versions / badge_id ; Value: TwitchChatBadge
func get_badges_data(channel_id: String = "global") -> Dictionary:
	return await icon_loader.get_cached_badges(channel_id);

## Gets the requested emotes.
## Key: EmoteID as String ; Value: SpriteFrame
func get_emotes(ids: Array[String]) -> Dictionary:
	return await icon_loader.get_emotes(ids);

## Gets the requested emotes in the specified theme, scale and type.
## Loads from cache if possible otherwise downloads and transforms them.
## Key: TwitchEmoteDefinition ; Value SpriteFrames
func get_emotes_by_definition(emotes: Array[TwitchEmoteDefinition]) -> Dictionary:
	return await icon_loader.get_emotes_by_definition(emotes);

## Get the requested badges. (valid scale values are 1,2,3)
## Loads from cache if possible otherwise downloads and transforms them.
## Key: Badge Composite ; Value: SpriteFrames
func get_badges(badge: Array[String], channel_id: String = "global", _scale: int = 1) -> Dictionary:
	return await icon_loader.get_badges(badge, channel_id);

func _init_cheermotes() -> void:
	cheer_repository = TwitchCheerRepository.new(api);

## Returns the complete parsed data out of a cheer word.
func get_cheer_tier(cheer_word: String,
	theme: TwitchCheerRepository.Themes = TwitchCheerRepository.Themes.DARK,
	type: TwitchCheerRepository.Types = TwitchCheerRepository.Types.ANIMATED,
	scale: TwitchCheerRepository.Scales = TwitchCheerRepository.Scales._1) -> TwitchCheerRepository.CheerResult:
	return await cheer_repository.get_cheer_tier(cheer_word, theme, type, scale);

## Returns the data of the Cheermotes.
func get_cheermote_data() -> Array[TwitchCheermote]:
	await cheer_repository.wait_is_ready();
	return cheer_repository.data;

## Checks if a prefix is existing.
func is_cheermote_prefix_existing(prefix: String) -> bool:
	return cheer_repository.is_cheermote_prefix_existing(prefix);

## Returns all cheertiers in form of:
## Key: TwitchCheermote.Tiers ; Value: SpriteFrames
func get_cheermotes(cheermote: TwitchCheermote,
	theme: TwitchCheerRepository.Themes = TwitchCheerRepository.Themes.DARK,
	type: TwitchCheerRepository.Types = TwitchCheerRepository.Types.ANIMATED,
	scale: TwitchCheerRepository.Scales = TwitchCheerRepository.Scales._1) -> Dictionary:
	return await cheer_repository.get_cheermotes(cheermote, theme, type, scale);

func add_command(command: String, callback: Callable, args_min: int = 0, args_max: int = -1,
	permission_level : TwitchCommandHandler.PermissionFlag = TwitchCommandHandler.PermissionFlag.EVERYONE,
	where : TwitchCommandHandler.WhereFlag = TwitchCommandHandler.WhereFlag.CHAT) -> void:

	l.i("Register command %s" % command)
	commands.add_command(command, callback, args_min, args_max, permission_level, where);

func remove_command(command: String) -> void:
	l.i("Remove command %s" % command)
	commands.remove_command(command);

func on_event(type : String, _data : Dictionary) -> void:
	var data := RSTwitchEventData.create_from_event_body(type, _data)
	match(type):
		"channel.follow": followed.emit(data)
		"channel.channel_points_custom_reward_redemption.add": channel_points_redeemed.emit(data)
		"channel.raid": raided.emit(data)
		"channel.cheer": cheered.emit(data)
		"channel.subscribe": subscribed.emit(data)

func is_magick_available() -> bool:
	var transformer = MagicImageTransformer.new()
	return transformer.is_supported()

func gather_user_info(username : String) -> RSTwitchUser:
	var user = RSTwitchUser.new()
	var response : TwitchGetUsersResponse = await api.get_users([], [username]) 
	if response.data.is_empty(): return
	user.user_id = response.data[0]["id"]
	user.display_name = response.data[0]["display_name"]
	user.username = response.data[0]["login"]
	user.profile_image_url = response.data[0]["profile_image_url"]
	return user

func get_live_streamers_data(user_names_or_ids : Array = []) -> Dictionary:
	if not is_connected_to_twitch:
		return {}

	if user_names_or_ids.is_empty():
		for user: RSTwitchUser in RS.user_mng.known.values():
			if user.get("is_streamer") != null:
				if user.is_streamer:
					user_names_or_ids.append(user.username)
	
	var live_streamers_data := {}
	var max_user_query = 10
	while not user_names_or_ids.is_empty():
		var names : Array[String] = []
		var ids : Array[String] = []
		var count = 0
		for i in range(user_names_or_ids.size()-1, -1, -1):
			var user_name_id = user_names_or_ids[i]
			user_names_or_ids.remove_at(i)
			if user_name_id is String:
				names.append(user_name_id)
			elif user_name_id is int:
				ids.append(str(user_name_id))
			
			if count > max_user_query:
				var res := await api.get_streams(ids, names, [], "live", [], 1, "", "")
				for stream : TwitchStream in res.data:
					live_streamers_data[stream.user_login] = stream
				break
			count += 1
	
	return live_streamers_data

func check_first_msg(_channel_name: String, username: String, _message: String, tags: TwitchTags.PrivMsg):
	if not username in first_session_message_username_list:
		first_session_message_username_list.append(username)
		first_session_message.emit(username, tags)

func check_user_twitch_color(username : String, tags: TwitchTags.PrivMsg) -> void:
	if tags.color.is_empty(): return
	if RS.user_mng.is_username_known(username):
		var user: RSTwitchUser = await RS.user_mng.get_user_from_username(username)
		if user.twitch_chat_color != Color(tags.color):
			user.twitch_chat_color = Color(tags.color)
			RSUserMng.save_user_to_json(user, RSSettings.get_users_path())

func raid(to_broadcaster_id : String):
	var path = "/helix/raids?from_broadcaster_id={from}&to_broadcaster_id={to}".format(
		{"from": str(RS.settings.broadcaster_id),
		"to":to_broadcaster_id})
	await api.request(path, HTTPClient.METHOD_POST, "", "application/x-www-form-urlencoded");

func get_follower_count() -> int:
	var path = "/helix/channels/followers?"
	path += "first=" + str(100) + "&"
	path += "broadcaster_id=" + str(RS.settings.broadcaster_id)
	var response = await api.request(path, HTTPClient.METHOD_GET, "", "application/json")
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	var parsed := TwitchGetChannelFollowersResponse.from_json(result)
	var count = parsed.data.size()
	
	while not parsed.pagination.cursor.is_empty():
		var pagination_path = path + "&after=%s" % parsed.pagination.cursor
		response = await api.request(pagination_path, HTTPClient.METHOD_GET, "", "application/json")
		result = JSON.parse_string(response.response_data.get_string_from_utf8())
		parsed = TwitchGetChannelFollowersResponse.from_json(result)
		count += parsed.data.size()
	
	return count

func get_moderators() -> Array[TwitchUserModerator]:
	var total : Array[TwitchUserModerator] = []
	
	var path = "/helix/moderation/moderators?"
	path += "first=" + str(100) + "&"
	path += "broadcaster_id=" + str(RS.settings.broadcaster_id)
	
	var response = await api.request(path, HTTPClient.METHOD_GET, "", "application/json")
	var result = JSON.parse_string(response.response_data.get_string_from_utf8())
	var parsed := TwitchGetModeratorsResponse.from_json(result)
	total.append_array( TwitchGetModeratorsResponse.from_json(result).data )
	
	while not parsed.pagination.cursor.is_empty():
		var pagination_path = path + "&after=%s" % parsed.pagination.cursor
		response = await api.request(pagination_path, HTTPClient.METHOD_GET, "", "application/json")
		result = JSON.parse_string(response.response_data.get_string_from_utf8())
		parsed = TwitchGetModeratorsResponse.from_json(result)
		total.append_array( TwitchGetModeratorsResponse.from_json(result).data )
	
	#return TwitchGetModeratorsResponse.from_json(result).data
	return total

	
