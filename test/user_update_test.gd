@tool
extends EditorScript



func _run() -> void:
	#var to_merge: Dictionary = {
		#"key1": 123,
		#"key2": [],
		#"key3": "TheYagich",
		#"key4": "",
	#}
	
	var orig_user: RSUser = RSUser.new()
	orig_user.user_id = 123
	orig_user.username = "g1ngercat"
	orig_user.display_name = "g1ngercat"
	orig_user.twitch_chat_color = Color.BLACK
	orig_user.profile_image_url = "url_orig"
	orig_user.is_streamer = true
	orig_user.auto_shoutout = false
	orig_user.auto_promotion = false
	orig_user.steam_app_ids = [123, 456]
	orig_user.work_with = 5
	orig_user.youtube_handle = "@b3agz"
	orig_user.website = "www.test.com"
	orig_user.shoutout_description = "g1ngercat is !b giganzo"
	
	var test_user := RSUser.from_json(orig_user.to_dict())
	
	var updated_user: RSUser = RSUser.new()
	updated_user.user_id = 123
	updated_user.username = "deferredcha"
	updated_user.display_name = "g1ngercat_is_now_deferredcha"
	updated_user.twitch_chat_color = Color.PURPLE
	updated_user.profile_image_url = ""
	updated_user.is_streamer = false
	updated_user.auto_shoutout = false
	updated_user.auto_promotion = false
	updated_user.steam_app_ids = []
	updated_user.work_with = 0
	updated_user.youtube_handle = ""
	updated_user.website = ""
	updated_user.shoutout_description = ""
	
	test_user.update_with_user(updated_user)
	print("=============== TEST update RSUser ===============")
	print_rich("user_id: [color=red]%s | [color=yellow]%s -> [color=green]%s" % [orig_user.user_id, updated_user.user_id, test_user.user_id])
	print_rich("username: [color=red]%s | [color=yellow]%s -> [color=green]%s" % [orig_user.username, updated_user.username, test_user.username])
	print_rich("display_name: [color=red]%s | [color=yellow]%s -> [color=green]%s" % [orig_user.display_name, updated_user.display_name, test_user.display_name])
	print_rich("twitch_chat_color: [color=red]%s | [color=yellow]%s -> [color=green]%s" % [orig_user.twitch_chat_color, updated_user.twitch_chat_color, test_user.twitch_chat_color])
	print_rich("profile_image_url: [color=red]%s | [color=yellow]%s -> [color=green]%s" % [orig_user.profile_image_url, updated_user.profile_image_url, test_user.profile_image_url])
	print_rich("is_streamer: [color=red]%s | [color=yellow]%s -> [color=green]%s" % [orig_user.is_streamer, updated_user.is_streamer, test_user.is_streamer])
	print_rich("auto_shoutout: [color=red]%s | [color=yellow]%s -> [color=green]%s" % [orig_user.auto_shoutout, updated_user.auto_shoutout, test_user.auto_shoutout])
	print_rich("auto_promotion: [color=red]%s | [color=yellow]%s -> [color=green]%s" % [orig_user.auto_promotion, updated_user.auto_promotion, test_user.auto_promotion])
	print_rich("steam_app_ids: [color=red]%s | [color=yellow]%s -> [color=green]%s" % [orig_user.steam_app_ids, updated_user.steam_app_ids, test_user.steam_app_ids])
	print_rich("work_with: [color=red]%s | [color=yellow]%s -> [color=green]%s" % [orig_user.work_with, updated_user.work_with, test_user.work_with])
	print_rich("youtube_handle: [color=red]%s | [color=yellow]%s -> [color=green]%s" % [orig_user.youtube_handle, updated_user.youtube_handle, test_user.youtube_handle])
	print_rich("website: [color=red]%s | [color=yellow]%s -> [color=green]%s" % [orig_user.website, updated_user.website, test_user.website])
	print_rich("shoutout_description: [color=red]%s | [color=yellow]%s -> [color=green]%s" % [orig_user.shoutout_description, updated_user.shoutout_description, test_user.shoutout_description])
