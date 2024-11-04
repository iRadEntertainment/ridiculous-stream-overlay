extends Node
class_name RSCustom

var main : RSMain
var l : RSLogger

const STREAM_OVERLAY_SCENE = "Overlay Stream"
# const STREAM_OVERLAY_VIDEOS = "Overlay Videos"

func start(_main : RSMain):
	main = _main
	l = RSLogger.new(RSSettings.LOGGER_NAME_CUSTOM)
	l.i("Started")
	main.twitcher.received_chat_message.connect(on_chat)
	main.twitcher.channel_points_redeemed.connect(on_channel_points_redeemed)
	main.twitcher.followed.connect(on_followed)
	main.twitcher.raided.connect(on_raided)
	main.twitcher.subscribed.connect(on_subscribed)
	main.twitcher.cheered.connect(on_cheered)
	main.twitcher.connected_to_twitch.connect(add_commands)
	main.twitcher.first_session_message.connect(on_first_session_message)


func add_commands() -> void:
	main.twitcher.commands.add_command("discord", discord)
	main.twitcher.commands.add_command("commands", chat_commands_help)
	main.twitcher.commands.add_command("pandano", pandano)
	main.twitcher.commands.add_command("whostream", whostream)
	
	main.twitcher.commands.add_command("b", spawn_can)
	
	main.twitcher.commands.add_command("laser", laser, 0, 1)
	main.twitcher.commands.add_command("nuke", nuke)
	main.twitcher.commands.add_command("grenade", spawn_grenade)
	main.twitcher.commands.add_alias("grenade", "granade")
	main.twitcher.commands.add_alias("grenade", "grandma")
	main.twitcher.commands.add_alias("grenade", "grenades")
	
	main.twitcher.commands.add_command("shake", shake_bodies)
	
	main.twitcher.commands.add_command("zeroG", zero_g)
	main.twitcher.commands.add_alias("zeroG", "zerog")
	main.twitcher.commands.add_alias("zeroG", "0g")
	main.twitcher.commands.add_alias("zeroG", "0G")
	
	main.twitcher.commands.add_command("tts", parse_tts_command, 1, 256)
	main.twitcher.commands.add_command("tts_gb", parse_tts_command.bind("en_GB"), 1, 256)
	main.twitcher.commands.add_command("tts_us", parse_tts_command.bind("en_US"), 1, 256)
	main.twitcher.commands.add_command("tts_it", parse_tts_command.bind("it_IT"), 1, 256)
	main.twitcher.commands.add_command("tts_es", parse_tts_command.bind("es_ES"), 1, 256)
	main.twitcher.commands.add_command("tts_fr", parse_tts_command.bind("fr_FR"), 1, 256)
	main.twitcher.commands.add_command("tts_de", parse_tts_command.bind("de_DE"), 1, 256)
	main.twitcher.commands.add_command("tts_pl", parse_tts_command.bind("pl_PL"), 1, 256)
	main.twitcher.commands.add_command("tts_ru", parse_tts_command.bind("ru_RU"), 1, 256)
	l.i("Command added to the handler.")

func on_chat(_channel_name: String, username: String, message: String, _tags: TwitchTags.PrivMsg):
	add_notification_scene(username)
	if "kiwi" in message.to_lower(): OS.shell_open("https://cdn.discordapp.com/attachments/1221896398706835527/1296143099478933566/IMG_2351.jpg?ex=671136d4&is=670fe554&hm=a909489ef95bd303ec49c2c559d869fc1da209e9ae3eb9a25ed085e055cdb183&")
	if username == "theyagich" and message == "wb!": yag_welcome_back()
	if "dawdle" in message: destructibles_names("dawdle")
	if message.begins_with("!quack"): main.play_sfx("quack")

func chat_on_stream_off(username: String) -> void:
	var message := "%s thank you for trying. The stream is off, but yeah, the plugin is still on..."%username
	main.twitcher.chat(message)

func on_first_session_message(username: String, _tags: TwitchTags.PrivMsg) -> void:
	if await !main.no_obs_ws.is_stream_on: return
	var user := await main.user_from_username(username)
	if username in main.known_users.keys():
		user.twitch_chat_color = await main.twitcher.get_user_color(str(user.user_id))
		main.loader.save_userfile(user)
	destructibles_names(username)
	if user.auto_shoutout:
		main.shoutout_mng.add_shoutout(user)
	# let the physic name appear in the editor


func on_channel_points_redeemed(data : RSTwitchEventData):
	l.i("Channel points redeemed. %s -> %s" % [data.username, data.reward_title] )
	var user := await main.user_from_username(data.username)
	#if await !main.no_obs_ws.is_stream_on: chat_on_stream_off(data.username); return
	match data.reward_title:
		"beans": beans(data.username)
		"open useless website": open_useless_website()
		"open browser history": open_browser_history()
		"Activate CoPilot for 5min": activate_copilot(300)
		"remove the cig break overlay": toggle_cig_overlay()
		"Give advice": main.vetting.custom_rewards_vetting(give_advice, data)
		"Get advice": get_advice(data)
		"Shut down stream": alert_on_stop_streaming(user, data)
		"Raid kani_dev": raid_kani(user, data)
		"Force raid a random streamer": main.alert_scene.wheel_of_random_raid(user, data.user_input)
		"Impersonate iRadDev": main.vetting.custom_rewards_vetting(impersonate_iRad, data)
		"Change Stream Title": main.vetting.custom_rewards_vetting(change_stream_title, data)
		"Do it!": play_doit()
		"Toggle mute mic on stream": main.no_obs_ws.toggle_mic_mute()
		"Granades!": main.physic_scene.spawn_grenade()
func on_followed(data : RSTwitchEventData):
	destructibles_names(data.username)
func on_raided(data : RSTwitchEventData):
	var raider_username = data.from_broadcaster_username
	destructibles_names(raider_username, data.viewers)
func on_subscribed(_data : RSTwitchEventData):
	pass
func on_cheered(_data : RSTwitchEventData):
	pass

func add_notification_scene(username: String) -> void:
	var new_notif_inst = RSGlobals.msg_notif_pack.instantiate()
	main.add_child(new_notif_inst)
	new_notif_inst.start(main, username)

func parse_tts_command(_info : TwitchCommandInfo = null, args := [], localizazion := "") -> void:
	var text = " ".join(args)
	if localizazion.is_empty():
		localizazion = ["en_GB","en_US","it_IT","es_ES","fr_FR","de_DE","pl_PL","ru_RU"].pick_random()
	tts(text, localizazion)

func play_doit():
	main.no_obs_ws.restart_media("do_it_%s.mp4" % randi_range(1,3))

func impersonate_iRad(data : RSTwitchEventData):
	var channel = data.user_input.split(" ", false, 1)[0].to_lower()
	#var msg = data.username + " wants me to tell you: "
	#msg += data.user_input.split(" ", false, 1)[1]
	var msg = data.user_input.split(" ", false, 1)[1]
	main.twitcher.irc.chat(msg, channel)

func give_advice(data : RSTwitchEventData) -> void:
	var folder_path = RSLoader.get_config_path()
	var advice_file = folder_path + "advice_collection.json"
	var advice_list : Array = []
	check_if_advice_file_exists(advice_file)
	advice_list = RSLoader.load_json(advice_file)
	var new_advice = {
		"adviser" : data.display_name,
		"advice" : data.user_input,
	}
	advice_list.append(new_advice)
	RSLoader.save_to_json(advice_file, advice_list)

func check_if_advice_file_exists(advice_file : String):
	if not FileAccess.file_exists(advice_file):
		var advice_list = [
				{
					"adviser" : "iRadDev",
					"advice" : "We don't have enough beans! MORE BEANS!"
				},
				{
					"adviser" : "robmblind",
					"advice" : "If you want to go fast, go alone. If you want to go far, go together."
				},
			]
		RSLoader.save_to_json(advice_file, advice_list)

func get_advice(data : RSTwitchEventData) -> void:
	var folder_path = RSLoader.get_config_path()
	var advice_file = folder_path + "advice_collection.json"
	var advice_list : Array
	check_if_advice_file_exists(advice_file)
	advice_list = RSLoader.load_json(advice_file)
	
	var advice = advice_list.pick_random()
	
	var advice_dic = {
		"user" : data.display_name,
		"adviser" : advice.adviser,
		"advice" : advice.advice,
	}
	var format_string : String = [
		'{user} you know what {adviser} said once? "{advice}"',
		'{user} you should listen to {adviser}: "{advice}"',
		'What {adviser} said to {user} resonated with him/her/they: "{advice}"',
		'{user} was reluctant to learn from {adviser}, but now he enjoys it: "{advice}"',
		'{user} attentively listen to {adviser}: "{advice}"',
		].pick_random()
	
	main.twitcher.chat(format_string.format(advice_dic) )


func discord(_info : TwitchCommandInfo = null, _args := []):
	var msg = "Join Discord: https://discord.gg/4YhKaHkcMb"
	main.twitcher.chat(msg)


func chat_commands_help(_info : TwitchCommandInfo = null, _args := []):
	var msg = "Use a combination of ![command] for chat: hl (highlight), hd(hidden), rb(rainbow), big, small, wave, pulse, tornado, shake"
	main.twitcher.chat(msg)


func beans(username : String):
	#if main.physic_scene.is_closing: return
	if username.is_empty():
		username = main.known_users.keys().pick_random()
	var beans_param := RSBeansParam.from_json(RSGlobals.params_can)
	var user := main.get_known_user(username.to_lower()) as RSTwitchUser
	if user:
		if user.custom_beans_params:
			beans_param = user.custom_beans_params
	main.physic_scene.add_image_bodies(beans_param)


func zero_g(_info : TwitchCommandInfo = null, _args := [], duration := 20.0):
	if not main.physic_scene:
		main.twitcher.chat("Wait for the physic scene to be in first!")
		return
	main.physic_scene.duration = duration
	main.physic_scene.zero_g()


func shake_bodies(_info : TwitchCommandInfo = null, _args := []) -> void:
	main.physic_scene.shake_bodies()

func laser(_info : TwitchCommandInfo = null, args := []):
	if main.physic_scene.is_closing: return
	const ANGLE_DEFAULT = PI/2.85
	var angle: float = float(args[0] if args.size() >= 1 else ANGLE_DEFAULT)
	main.physic_scene.add_laser(angle)

func spawn_can(_info : TwitchCommandInfo = null, _args := []) -> void:
	var param := RSBeansParam.new()
	param.img_paths = ["can.png"]
	param.sfx_paths = [
			"sfx_can_01.ogg",
			"sfx_can_02.ogg",
			"sfx_can_03.ogg",
			"sfx_can_04.ogg",
		]
	param.spawn_range = [1,1]
	param.is_destroy = true
	param.is_pickable = true
	param.scale = Vector2.ONE * randf_range(0.15, 0.35)
	main.physic_scene.add_image_bodies(param)

func spawn_grenade(_info : TwitchCommandInfo = null, _args := []) -> void:
	main.physic_scene.spawn_grenade()

func nuke(_info : TwitchCommandInfo = null, _args := []):
	main.physic_scene.nuke()

func destructibles_names(username := "", quantity : int = 1, font_size := 96):
	var user: RSTwitchUser
	if username.is_empty():
		username = main.known_users.keys().pick_random()
		user = main.known_users[username]
		if user.twitch_chat_color == Color.BLACK:
			user.twitch_chat_color = await main.twitcher.get_user_color(str(user.user_id))
			main.loader.save_userfile(user)
	else:
		user = await main.user_from_username(username)
	
	var col :=  Color("#00ec4f")
	if user.twitch_chat_color != Color.BLACK:
		col = user.twitch_chat_color
	elif user.custom_chat_color != Color.BLACK:
		col = user.custom_chat_color
	
	if username == "dawdle":
		font_size = 32
		quantity *= 10
	
	for _i in quantity:
		await get_tree().process_frame
		main.physic_scene.generate_text_rigidbody(user.display_name, col, font_size)

func pandano(_info : TwitchCommandInfo = null, _args := []):
	main.no_obs_ws.restart_media("Panda_no")

func whostream(_info : TwitchCommandInfo = null, _args := []) -> void:
	var streamers_live_data = await main.twitcher.get_live_streamers_data()
	var msg: String = "Currently streaming:"
	for key in streamers_live_data.keys():
		msg += " %s" % key
	main.twitcher.chat(msg)

#endregion


func toggle_cig_overlay():
	var item_id = await main.no_obs_ws.get_scene_item_id(STREAM_OVERLAY_SCENE, "BRB_text")
	var scene_item_enabled = await main.no_obs_ws.get_item_enabled(STREAM_OVERLAY_SCENE, item_id)
	main.no_obs_ws.set_item_enabled(STREAM_OVERLAY_SCENE, item_id, !scene_item_enabled)


func suggest_no_ads(on_cig_break_activation := true) -> void:
	if on_cig_break_activation:
		var item_id = await main.no_obs_ws.get_scene_item_id(STREAM_OVERLAY_SCENE, "BRB_text")
		var scene_item_enabled = await main.no_obs_ws.get_item_enabled(STREAM_OVERLAY_SCENE, item_id)
		if scene_item_enabled: return
	var streamers_live_data = await main.twitcher.get_live_streamers_data()
	var suggested_streamer = streamers_live_data.keys().pick_random()
	var msg := """Do not watch the ADS.
	 Excessive ad exposure manipulates behavior, fuels anxiety, and undermines mental well-being by promoting
	unrealistic standards and decision fatigue. Watch twitch.tv/%s instead, they are live NOW!"""%suggested_streamer
	main.twitcher.chat(msg)


func alert_on_stop_streaming(user: RSTwitchUser, data: RSTwitchEventData):
	main.alert_scene.initialize_stop_streaming(user, data.user_input)


func stop_streaming():
	main.no_obs_ws.stop_stream()


func raid_kani(user: RSTwitchUser, data: RSTwitchEventData):
	var kani_rs_user := main.get_known_user("kani_dev")
	main.alert_scene.initialize_raid(user, kani_rs_user, data.user_input)


#func raid_a_random_streamer_from_the_user_list():
	#var streamers_live_data = await main.twitcher.get_live_streamers_data()
	#main.wheel_of_random.streamers_live_data = streamers_live_data
	#main.wheel_of_random.spin_for_streamers()


func save_all_scenes_and_scripts():
	pass

func open_useless_website():
	OS.shell_open("https://theuselessweb.com/")
func open_browser_history():
	OS.execute("C:/Program Files/BraveSoftware/Brave-Browser/Application/brave.exe", ['about:history'])
func activate_copilot(secondos : float):
	main.copilot.activate(secondos)
func open_silent_itch_io_page():
	pass
func play_carbrix_or_woop():
	pass
func play_kerker():
	OS.execute("C:\\Users\\Dario\\Desktop\\Kerker.exe", [])


func change_stream_title(data : RSTwitchEventData):
	var title = "%s - %s"%[data.user_input, data.username]
	var path = "/helix/channels?"
	path += "broadcaster_id=" + str(TwitchSetting.broadcaster_id) + "&"
	await main.twitcher.api.request(path, HTTPClient.METHOD_PATCH, {"title":title}, "application/json")


func iRad_follow_somebody(_data : RSTwitchEventData):
	pass
	# main.twitcher.api.get_followed_channels(

#"!tts" == "en_GB"
#"!tts_us" == "en_US"
#"!tts_it" == "it_IT"
#"!tts_es" == "es_ES"
#"!tts_fr" == "fr_FR"
#"!tts_de" == "de_DE"
#"!tts_pl" == "pl_PL"
#"!tts_ru" == "ru_RU"
##"!tts_dk" == "dk_DK"
##"!tts_ro" == "ro_RO"
##"!tts_aus" == "en_AS"

##(0)en_US: TTS_MS_EN-US_DAVID_11.0
##(1)en_GB: TTS_MS_EN-GB_HAZEL_11.0
##(2)de_DE: TTS_MS_DE-DE_HEDDA_11.0
##(3)en_US: TTS_MS_EN-US_ZIRA_11.0
##(4)es_ES: TTS_MS_ES-ES_HELENA_11.0
##(5)fr_FR: TTS_MS_FR-FR_HORTENSE_11.0
##(6)it_IT: TTS_MS_IT-IT_ELSA_11.0
##(7)pl_PL: TTS_MS_PL-PL_PAULINA_11.0
##(8)ru_RU: TTS_MS_RU-RU_IRINA_11.0

func tts(text: String, localization := "en_GB") -> void:
	var voices = DisplayServer.tts_get_voices()
	if not voices: return
	#print("================ TTS =================")
	#for i in voices.size():
		#var v = voices[i]
		#print("(%s)%s: %s" % [i, v.language, v.name])
	
	await get_tree().create_timer(0.75).timeout
	var speed = 1 #randf_range(0.9, 1.1)
	var pitch = 1 #randf_range(0.3, 0.4)
	var voice_ids = []
	for v: Dictionary in voices:
		if v.language == localization:
			voice_ids.append(v.id)
	var voice_id
	if voice_ids.is_empty():
		voice_id = voices.pick_random().id
	else:
		voice_id = voice_ids.pick_random()
	DisplayServer.tts_speak(text, voice_id, 100, pitch, speed)
	#DisplayServer.tts_speak(text, voice_id, 100)


func yag_welcome_back():
	for i in 10:
		beans("theyagich")
		await get_tree().process_frame
	await get_tree().create_timer(1).timeout
	tts("The Yagich welcomes the streamer back!")
