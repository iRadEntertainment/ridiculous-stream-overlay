# panel twitch users

extends PanelContainer

signal user_selected(user, live_data)

var filter_live := false


func start() -> void:
	populate_user_button_list()
	
	%pnl_loading_live.stop()
	RS.user_mng.live_streamers_updating.connect(_on_live_streamers_updating)
	RS.user_mng.live_streamers_updated.connect(_on_live_streamers_updated)
	RS.user_mng.known_users_updated.connect(_on_known_users_updated)


func populate_user_button_list() -> void:
	%ln_filter.text = ""
	for btn in %user_list.get_children():
		btn.queue_free()
	
	for user_id in RS.user_mng.known.keys():
		add_user_btn_entry_from_user_id(user_id)


func add_user_btn_entry_from_user_id(user_id: int) -> void:
	var user: RSUser = RS.user_mng.known[user_id]
	if not user: return
	var btn_user_instance: RSTwitchUserEntry = RSGlobals.btn_user_pack.instantiate()
	btn_user_instance.user = user
	btn_user_instance.user_selected.connect(user_selected_pressed)
	%user_list.add_child(btn_user_instance)


func toggle_live_users(toggled_on: bool) -> void:
	for user_button in %user_list.get_children():
		user_button.visible = !toggled_on or \
				user_button.user.user_id in RS.user_mng.live_streamers_data.keys()


## Called by btn_user_instance
func user_selected_pressed(btn_user: RSUser) -> void:
	%ln_filter.text = ""
	var user: RSUser = await RS.user_mng.known.get(btn_user.user_id)
	var live_data: TwitchStream = RS.user_mng.live_streamers_data.get(btn_user.user_id)
	user_selected.emit(user, live_data)


func _on_live_streamers_updating() -> void:
	%pnl_loading_live.start()
func _on_live_streamers_updated() -> void:
	%pnl_loading_live.stop()
func _on_known_users_updated() -> void:
	var known_ids: Array = RS.user_mng.known.keys()
	for btn: RSTwitchUserEntry in %user_list.get_children():
		var user: RSUser = btn.user
		known_ids.erase(user.user_id)
		if not user.user_id in RS.user_mng.known.keys():
			btn.queue_free()
	
	for user_id: int in known_ids:
		add_user_btn_entry_from_user_id(user_id)


func _on_btn_filter_live_pressed() -> void:
	filter_live = !filter_live
	toggle_live_users(filter_live)
func _on_btn_reload_pressed() -> void:
	RS.user_mng.refresh_live_streamers()
	
func _on_ln_filter_text_changed(new_text: String) -> void:
	new_text = new_text.to_lower()
	for user_line in %user_list.get_children():
		user_line.visible = user_line.user.username.find(new_text) != -1 or new_text.is_empty()
