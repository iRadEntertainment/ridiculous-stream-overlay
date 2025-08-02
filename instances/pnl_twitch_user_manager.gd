# pgorley is the best

# download carbrix now
extends PanelContainer

var user: RSUser


func _ready():
	set_process(false)


func start():
	set_tab_names()


func set_tab_names():
	for pnl in %tabs.get_children():
		var tab_title = pnl.name.trim_prefix("pnl_").capitalize()
		%tabs.set_tab_title(pnl.get_index(), tab_title)


func populate_fields(_user: RSUser, _live_data: TwitchStream):
	user = _user
	%pnl_rs_twitch_user_info.user = _user
	
	var live_tab_idx = %tabs.get_tab_idx_from_control(%pnl_user_live)
	var info_tab_idx = %tabs.get_tab_idx_from_control(%pnl_rs_twitch_user_info)
	%tabs.set_tab_disabled(live_tab_idx, _live_data == null)
	%tabs.current_tab = live_tab_idx if _live_data else info_tab_idx
	%pnl_user_live.populate(_live_data)


func _on_btn_open_folder_pressed():
	OS.shell_open(RSSettings.get_users_path())


func _on_opt_custom_sfx_item_selected(index):
	%sfx_prev.stop()
	var sfx_name = %opt_custom_sfx.get_item_text(index)
	%sfx_prev.stream = RS.loader.load_sfx_from_sfx_folder(sfx_name)
	%sfx_prev.play()
