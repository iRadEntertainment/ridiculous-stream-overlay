# panel twitch users

extends PanelContainer

signal user_selected(user, live_data)

var filter_live := false

func start():
	populate_user_button_list()


func populate_user_button_list():
	%ln_filter.text = ""
	for btn in %user_list.get_children():
		btn.queue_free()
	
	for user_id in RS.user_mng.known.keys():
		var user := RS.user_mng.known[user_id] as RSTwitchUser
		if not user: continue
		var btn_user_instance: RSTwitchUserEntry = RSGlobals.btn_user_pack.instantiate()
		btn_user_instance.user = user
		btn_user_instance.user_selected.connect(user_selected_pressed)
		%user_list.add_child(btn_user_instance)


## Called by btn_user_instance
func user_selected_pressed(btn_user: RSTwitchUser) -> void:
	%ln_filter.text = ""
	var user: RSTwitchUser = await RS.user_mng.known.get(btn_user.user_id)
	var live_data: TwitchStream = RS.user_mng.live_streamers_data.get(btn_user.user_id)
	user_selected.emit(user, live_data)


func _on_btn_filter_live_pressed():
	filter_live = !filter_live
	for user_button in %user_list.get_children():
		user_button.visible = !filter_live or user_button.user.user_id in RS.user_mng.live_streamers_data.keys()
#func _on_btn_check_live_pressed():
	#var live_data := await RS.gift.get_live_streamers_data()
	#
	#for user_button in %user_list.get_children():
		#user_button.visible = user_button.user.username in live_data.keys()
		#if user_button.user.username in live_data.keys():
			#user_button.live_data = live_data[user_button.user.username]
		#else:
			#user_button.live_data = null

func _on_btn_reload_pressed():
	RS.user_mng.refresh_live_streamers()
	for key in RS.user_mng.live_streamers_data.keys():
		print(key)
	print("live: %d" % RS.user_mng.live_streamers_data.size())
func _on_ln_filter_text_changed(new_text: String):
	new_text = new_text.to_lower()
	for user_line in %user_list.get_children():
		user_line.visible = user_line.user.username.find(new_text) != -1 or new_text.is_empty()
