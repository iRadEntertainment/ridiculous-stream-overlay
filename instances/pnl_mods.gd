extends PanelContainer


func _ready() -> void:
	await RS.all_started
	RS.twitcher.connected_to_twitch.connect(refresh_data)


func refresh_data() -> void:
	%pnl_loading_simple.show()
	
	var num_followers: int = await RS.twitcher.get_follower_count()
	var mods: Array[TwitchUserModerator] = await RS.twitcher.get_moderators()
	var ratio = mods.size()/float(num_followers)
	%lb_mod_stats.text = str(mods.size())
	%lb_foll_stats.text = str(num_followers)
	%lb_mod_ratio.text = ("%2.2f" % [(ratio * 100)]) + "%"
	
	%pnl_loading_simple.hide()


func _on_btn_refresh_mods_pressed() -> void:
	refresh_data()
