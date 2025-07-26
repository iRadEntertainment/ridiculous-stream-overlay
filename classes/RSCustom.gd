extends Node
class_name RSCustom

static var _log: TwitchLogger = TwitchLogger.new(&"RSCustom")

const STREAM_OVERLAY_SCENE = "Overlay Stream"
# const STREAM_OVERLAY_VIDEOS = "Overlay Videos"


func start():
	_log.i("Started")
	RS.twitcher.received_chat_message.connect(on_chat)
	RS.twitcher.channel_points_redeemed.connect(on_channel_points_redeemed)
	RS.twitcher.followed.connect(on_followed)
	RS.twitcher.raided.connect(on_raided)
	RS.twitcher.subscribed.connect(on_subscribed)
	RS.twitcher.cheered.connect(on_cheered)
	RS.twitcher.connected_to_twitch.connect(add_commands)
	RS.twitcher.first_session_message.connect(on_first_session_message)


func add_commands() -> void:
	RS.twitcher.add_command("add_me", RS.user_mng._on_user_request_add)
	
	RS.twitcher.add_command("discord", discord)
	RS.twitcher.add_command("commands", chat_commands_help)
	RS.twitcher.add_command("pandano", pandano)
	RS.twitcher.add_command("whostream", whostream)
	
	RS.twitcher.add_command("b", spawn_fake_beans, 0, 1)
	RS.twitcher.add_command("d", play_discord_notification)
	RS.twitcher.add_command("n", add_name_to_scene)
	RS.twitcher.add_command("toggle_music", toggle_music)
	RS.twitcher.add_command("mika", play_mika_system_of_a_down)
	RS.twitcher.add_command("snow", let_it_snow)
	
	RS.twitcher.add_command("laser", laser, 0, 1)
	RS.twitcher.add_command("nuke", nuke)
	RS.twitcher.add_command("g", spawn_grenade, 0, 1)
	#RS.twitcher.add_alias("g", "grenade")
	#RS.twitcher.add_alias("grenade", "granade")
	#RS.twitcher.add_alias("grenade", "grandma")
	#RS.twitcher.add_alias("grenade", "grenades")
	
	RS.twitcher.add_command("shake", shake_bodies)
	
	RS.twitcher.add_command("zeroG", zero_g)
	#RS.twitcher.add_alias("zeroG", "zerog")
	#RS.twitcher.add_alias("zeroG", "0g")
	#RS.twitcher.add_alias("zeroG", "0G")
	
	#RS.twitcher.add_command("tts", parse_tts_command, 1, 256)
	#RS.twitcher.add_command("tts_gb", parse_tts_command.bind("en_GB"), 1, 256)
	#RS.twitcher.add_command("tts_us", parse_tts_command.bind("en_US"), 1, 256)
	#RS.twitcher.add_command("tts_it", parse_tts_command.bind("it_IT"), 1, 256)
	#RS.twitcher.add_command("tts_es", parse_tts_command.bind("es_ES"), 1, 256)
	#RS.twitcher.add_command("tts_fr", parse_tts_command.bind("fr_FR"), 1, 256)
	#RS.twitcher.add_command("tts_de", parse_tts_command.bind("de_DE"), 1, 256)
	#RS.twitcher.add_command("tts_pl", parse_tts_command.bind("pl_PL"), 1, 256)
	#RS.twitcher.add_command("tts_ru", parse_tts_command.bind("ru_RU"), 1, 256)
	_log.i("Command added to the handler.")

func on_chat(t_message: TwitchChatMessage) -> void:
	var message: String = t_message.message.text
	var user_id: int = int(t_message.chatter_user_id)
	var user: RSUser = await RS.user_mng.get_user_from_user_id(user_id)
	if not message.begins_with("!"):
		add_notification_scene(user)
	if "kiwi" in message.to_lower(): OS.shell_open("https://cdn.discordapp.com/attachments/1221896398706835527/1296143099478933566/IMG_2351.jpg?ex=671136d4&is=670fe554&hm=a909489ef95bd303ec49c2c559d869fc1da209e9ae3eb9a25ed085e055cdb183&")
	if t_message.chatter_user_name == "theyagich" and message == "wb!": yag_welcome_back()
	if "dawdle" in message: destructibles_names("dawdle")
	if message.begins_with("!quack"): RS.play_sfx("quack")

func chat_on_stream_off(username: String) -> void:
	var message := "%s thank you for trying. The stream is off, but yeah, the plugin is still on..."%username
	RS.twitcher.chat(message)

func on_first_session_message(t_message: TwitchChatMessage) -> void:
	if !RS.no_obs_ws.is_stream_on: return
	var user_id: int = int(t_message.chatter_user_id)
	var user: RSUser = await RS.user_mng.get_user_from_user_id(user_id)
	if RS.user_mng.is_user_id_known(user_id):
		user.twitch_chat_color = await RS.twitcher.get_user_color(user.user_id)
		# TODO: move this to user manager
		RS.user_mng.save_user(user)
	destructibles_names(t_message.chatter_user_name)
	if user.auto_shoutout:
		RS.shoutout_mng.add_shoutout(user)
	# let the physic name appear in the editor


func on_channel_points_redeemed(data : RSTwitchEventData):
	_log.i("Channel points redeemed. %s -> %s" % [data.username, data.reward_title] )
	var user: RSUser = await RS.user_mng.get_user_from_username(data.username)
	#if await !RS.no_obs_ws.is_stream_on: chat_on_stream_off(data.username); return
	match data.reward_title:
		"beans": beans(data.username)
		"open useless website": open_useless_website()
		"open browser history": open_browser_history()
		"remove the cig break overlay": toggle_cig_overlay()
		"Give advice": RS.vetting.custom_rewards_vetting(give_advice, data)
		"Get advice": get_advice(data)
		"Shut down stream": alert_on_stop_streaming(user, data)
		"Raid kani_dev": raid_kani(user, data)
		"Force raid a random streamer": RS.alert_scene.wheel_of_random_raid(user, data.user_input)
		"Impersonate iRadDev": RS.vetting.custom_rewards_vetting(impersonate_iRad, data)
		"Change Stream Title": RS.vetting.custom_rewards_vetting(change_stream_title, data)
		"Do it!": play_doit()
		"Toggle mute mic on stream": RS.no_obs_ws.toggle_mic_mute()
		"Granades!": RS.physic_scene.spawn_grenade()
		"Change streamer colour": change_streamer_colour(data.user_input)
func on_followed(data : RSTwitchEventData):
	destructibles_names(data.username)
func on_raided(data : RSTwitchEventData):
	var raider_username = data.from_broadcaster_username
	destructibles_names(raider_username, data.viewers)
func on_subscribed(_data : RSTwitchEventData):
	pass
func on_cheered(_data : RSTwitchEventData):
	pass


func add_notification_scene(user: RSUser) -> void:
	var new_notif_inst = RSGlobals.msg_notif_pack.instantiate()
	RS.add_child(new_notif_inst)
	new_notif_inst.start(user)


func parse_tts_command(_info : TwitchCommandInfo = null, args := [], localizazion := "") -> void:
	var text = " ".join(args)
	if localizazion.is_empty():
		localizazion = ["en_GB","en_US","it_IT","es_ES","fr_FR","de_DE","pl_PL","ru_RU"].pick_random()
	tts(text, localizazion)

func play_doit():
	RS.no_obs_ws.restart_media("do_it_%s.mp4" % randi_range(1,3))


func change_streamer_colour(user_input: String) -> void:
	if not user_input.is_valid_html_color():
		_log.w("Change streamer colour didn't work. Colour: #%s" % user_input)
		return
	
	var col: Color = Color.html(user_input)
	
	var val: int = (col.b8 << 16) | (col.g8 << 8) | col.r8
	
	var settings_cutout: Dictionary = {
		"color_multiply": val,
	}
	var settings_composite: Dictionary = {
		"opacity": col.a,
	}
	RS.no_obs_ws.set_item_filter_setting("Cam-cutout", "Colour Correction", settings_cutout)
	RS.no_obs_ws.set_item_filter_setting("Cam-composite", "Colour Correction", settings_composite)


func impersonate_iRad(data : RSTwitchEventData):
	var broadcaster_login = data.user_input.split(" ", false, 1)[0]
	broadcaster_login = broadcaster_login.strip_edges()
	broadcaster_login = broadcaster_login.lstrip("@")
	broadcaster_login = broadcaster_login.to_lower()
	#var msg = data.username + " wants me to tell you: "
	#msg += data.user_input.split(" ", false, 1)[1]
	var msg = data.user_input.split(" ", false, 1)[1]
	RS.twitcher.irc.chat(msg, broadcaster_login)

func give_advice(data : RSTwitchEventData) -> void:
	var folder_path := RSSettings.data_dir
	var advice_file = folder_path + "/advice_collection.json"
	var advice_list : Array = []
	check_if_advice_file_exists(advice_file)
	advice_list = RSUtl.load_json(advice_file)
	var new_advice = {
		"adviser" : data.display_name,
		"advice" : data.user_input,
	}
	advice_list.append(new_advice)
	RSUtl.save_to_json(advice_file, advice_list)

func check_if_advice_file_exists(advice_file : String):
	if not FileAccess.file_exists(advice_file):
		var advice_list = [
				{
					"adviser": "iRadDev",
					"advice": "We don't have enough beans! MORE BEANS!"
				},
				{
					"adviser": "robmblind",
					"advice": "If you want to go fast, go alone. If you want to go far, go together."
				},
			]
		RSUtl.save_to_json(advice_file, advice_list)

func get_advice(data : RSTwitchEventData) -> void:
	var folder_path := RSSettings.data_dir
	var advice_file = folder_path + "/advice_collection.json"
	var advice_list : Array
	check_if_advice_file_exists(advice_file)
	advice_list = RSUtl.load_json(advice_file)
	
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
	
	RS.twitcher.chat(format_string.format(advice_dic) )


func discord(_info : TwitchCommandInfo = null, _args := []):
	RS.play_sfx("discord")
	var msg = "Join Discord: https://discord.gg/4YhKaHkcMb"
	RS.twitcher.chat(msg)


func chat_commands_help(_info : TwitchCommandInfo = null, _args := []):
	var msg = "Use a combination of ![command] for chat: hl (highlight), hd(hidden), rb(rainbow), big, small, wave, pulse, tornado, shake"
	RS.twitcher.chat(msg)


func beans(username : String):
	#if RS.physic_scene.is_closing: return
	var user: RSUser
	if username.is_empty() and !RS.user_mng.known.is_empty():
		user = RS.user_mng.known.values().pick_random()
	elif not username.is_empty():
		user = await RS.user_mng.get_user_from_username(username.to_lower())
	
	var beans_param := RSBeansParam.from_json(RSGlobals.PARAMS_CANS)
	if user:
		if user.custom_beans_params:
			beans_param = user.custom_beans_params
	RS.physic_scene.add_image_bodies(beans_param)


func zero_g(_info : TwitchCommandInfo = null, _args := [], duration := 20.0):
	if not RS.physic_scene:
		RS.twitcher.chat("Wait for the physic scene to be in first!")
		return
	RS.physic_scene.duration = duration
	RS.physic_scene.zero_g()


func shake_bodies(_info : TwitchCommandInfo = null, _args := []) -> void:
	RS.physic_scene.shake_bodies()


func laser(_info : TwitchCommandInfo = null, args := []):
	if RS.physic_scene.is_closing: return
	const ANGLE_DEFAULT = PI/2.85
	var angle: float = float(args[0] if args.size() >= 1 else ANGLE_DEFAULT)
	RS.physic_scene.add_laser(angle)


func spawn_fake_beans(_info : TwitchCommandInfo = null, args := []) -> void:
	var fake_beans := RSBeansParam.new()
	fake_beans.img_paths = ["can.png"]
	fake_beans.sfx_paths = ["sfx_notification_discord.ogg"]
	fake_beans.sfx_volume = -12
	fake_beans.is_destroy = true
	fake_beans.is_pickable = true
	fake_beans.scale = randf_range(0.10, 0.25)
	
	var count: int = 1
	if !args.is_empty():
		count = ceili( float(args[0]) )
		if count != 69:
			count = wrapi(count, 0, 6)
		
		match args[0]:
			"temptic":
				count = [4, 40, 404].pick_random()
				fake_beans.sfx_paths = ["sfx_notification_discord.ogg"]
				fake_beans.img_paths = [
					"fishBlue.png",
					"fishGray.png",
					"fishGreen.png",
					"fishOrange.png",
					"fishYellow.png",
					"fishRed.png",
					"fishPink.png",
					"fishPurple.png",
				]
				fake_beans.scale = randf_range(0.6, 0.8)
				await get_tree().create_timer(1.5).timeout
				zero_g()
			"giganzo":
				count = 100
			"jake":
				fake_beans.img_paths = ["pickle.png", "pickle_jar.png"]
				fake_beans.scale = randf_range(0.3, 0.6)
				count = 69
			"anihan":
				var rand_idx: int = randi_range(0,1)
				fake_beans.img_paths = [
					[
						"bean_03.png",
						"bean_04.png",
						"bean_05.png",
						"bean_06.png",
					],
					[
						"cheese_01_swiss.png",
						"cheese_02_swiss.png",
						"cheese_03_swiss.png",
						"cheese_04_cheddar.png",
						"cheese_05_provolone.png",
						"cheese_06_gouda.png",
						"cheese_07_gouda.png",
						"cheese_08_muenster.png",
						"cheese_09_colbyjack.png",
						"cheese_10_colbyjack.png",
					]
				][rand_idx]
				fake_beans.scale = [randf_range(3.0, 4.0), randf_range(0.8, 1.0)][rand_idx]
				count = [420, 128][rand_idx]
			"vex":
				fake_beans.img_paths = ["vex.png"]
				fake_beans.scale = randf_range(0.25, 0.35)
				count = 667
				var msg = "BUY Zooika! by Vex667 <3 -> https://s.team/a/2994730 <-"
				RS.twitcher.chat(msg)
	
	for i: int in count:
		fake_beans.coll_mask = fake_beans.coll_layer + 0b001
		RS.physic_scene.add_image_bodies(fake_beans)
		if RS.physic_scene.obj_count > RS.physic_scene.SHARD_BODIES_CAP:
			break
		await get_tree().create_timer(0.03).timeout


func spawn_grenade(_info : TwitchCommandInfo = null, args := []) -> void:
	var count: int = 1
	if !args.is_empty():
		count = ceili( float(args[0]) )
		if count != 69:
			count = wrapi(count, 0, 6)
	
	for i: int in count:
		RS.physic_scene.spawn_grenade()
		if RS.physic_scene.obj_count >= RS.physic_scene.SHARD_BODIES_CAP + 10:
			break
		await get_tree().create_timer(0.03).timeout


func play_discord_notification(_info : TwitchCommandInfo = null, _args := []) -> void:
	RS.play_sfx("discord")


func add_name_to_scene(info : TwitchCommandInfo = null, _args := []) -> void:
	destructibles_names(info.username, 1, 48)


func toggle_music(_info : TwitchCommandInfo = null, _args := []) -> void:
	var is_mozilla_input_mute: bool = await RS.no_obs_ws.get_input_mute("Mozilla")
	RS.no_obs_ws.set_input_mute("Mozilla", !is_mozilla_input_mute)


func play_mika_system_of_a_down(_info : TwitchCommandInfo = null, _args := []) -> void:
	$sfx_custom.stop()
	$sfx_custom.stream = RS.loader.load_sfx_from_sfx_folder("sfx_chop_suey_by_Mika.ogg")
	$sfx_custom.play()


func nuke(_info : TwitchCommandInfo = null, _args := []):
	RS.physic_scene.nuke()


func destructibles_names(username := "", quantity : int = 1, font_size := 96):
	var user: RSUser
	if username.is_empty() and !RS.user_mng.known.is_empty():
		user = RS.user_mng.known.values().pick_random()
	else:
		user = await RS.user_mng.get_user_from_username(username)
	
	var col :=  Color("00ec4f")
	if user.twitch_chat_color != Color.BLACK:
		col = user.twitch_chat_color
	elif user.custom_chat_color != Color.BLACK:
		col = user.custom_chat_color
	
	if username == "dawdle":
		font_size = 32
		quantity *= 10
	
	for _i in quantity:
		await get_tree().process_frame
		RS.physic_scene.generate_text_rigidbody(user.display_name, col, font_size)

func pandano(_info : TwitchCommandInfo = null, _args := []):
	RS.no_obs_ws.restart_media("Panda_no")

func whostream(_info : TwitchCommandInfo = null, _args := []) -> void:
	var streamers_live_data = await RS.twitcher.get_live_streamers_data()
	var msg: String = "Currently streaming:"
	for key in streamers_live_data.keys():
		msg += " %s" % (RS.user_mng.get_known_user_from_user_id(key).display_name)
	RS.twitcher.chat(msg)
#endregion


func toggle_cig_overlay():
	var item_id = await RS.no_obs_ws.get_scene_item_id(STREAM_OVERLAY_SCENE, "BRB_text")
	var scene_item_enabled = await RS.no_obs_ws.get_item_enabled(STREAM_OVERLAY_SCENE, item_id)
	RS.no_obs_ws.set_item_enabled(STREAM_OVERLAY_SCENE, item_id, !scene_item_enabled)


func suggest_no_ads(on_cig_break_activation := true) -> void:
	if on_cig_break_activation:
		var item_id = await RS.no_obs_ws.get_scene_item_id(STREAM_OVERLAY_SCENE, "BRB_text")
		var scene_item_enabled = await RS.no_obs_ws.get_item_enabled(STREAM_OVERLAY_SCENE, item_id)
		if scene_item_enabled: return
	var streamers_live_data: Dictionary[int, TwitchStream] = await RS.twitcher.get_live_streamers_data()
	if streamers_live_data.is_empty():
		return
	var suggested_streamer_id: int = streamers_live_data.keys().pick_random()
	var streamer: RSUser = RS.user_mng.get_known_user_from_user_id(suggested_streamer_id)
	var msg := """Do not watch the ADS.
	 Excessive ad exposure manipulates behavior, fuels anxiety, and undermines mental well-being by promoting
	unrealistic standards and decision fatigue. Watch twitch.tv/%s instead, they are live NOW!""" % streamer.username
	RS.twitcher.chat(msg)


func alert_on_stop_streaming(user: RSUser, data: RSTwitchEventData):
	RS.alert_scene.initialize_stop_streaming(user, data.user_input)


func stop_streaming():
	RS.no_obs_ws.stop_stream()


func raid_kani(user: RSUser, data: RSTwitchEventData):
	var kani_rs_user: RSUser = await RS.user_mng.get_user_from_username("kani_dev")
	RS.alert_scene.initialize_raid(user, kani_rs_user, data.user_input)


#func raid_a_random_streamer_from_the_user_list():
	#var streamers_live_data = await RS.twitcher.get_live_streamers_data()
	#RS.wheel_of_random.streamers_live_data = streamers_live_data
	#RS.wheel_of_random.spin_for_streamers()


func save_all_scenes_and_scripts():
	pass

func open_useless_website():
	OS.shell_open("https://theuselessweb.com/")
func open_browser_history():
	OS.execute("C:/Program Files/BraveSoftware/Brave-Browser/Application/brave.exe", ['brave://history'])
func open_silent_itch_io_page():
	pass
func play_carbrix_or_woop():
	pass
func play_kerker():
	OS.execute("C:\\Users\\Dario\\Desktop\\Kerker.exe", [])


func change_stream_title(data : RSTwitchEventData):
	var title = "%s - %s"%[data.user_input, data.username]
	var path = "/helix/channels?"
	path += "broadcaster_id=" + str(RS.settings.broadcaster_id) + "&"
	await RS.twitcher.api.request(path, HTTPClient.METHOD_PATCH, {"title":title}, "application/json")


func iRad_follow_somebody(_data : RSTwitchEventData):
	pass
	# RS.twitcher.api.get_followed_channels(

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


func let_it_snow(_info: TwitchCommandInfo = null, _args := []) -> void:
	if RS.manadono_snow.visible:
		return
	RS.manadono_snow.show()
	await get_tree().create_timer(10.0).timeout
	RS.manadono_snow.hide()
