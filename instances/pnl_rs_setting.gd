
extends PanelContainer



func start():
	%sl_window_scale.value = RS.settings.app_scale
	%ln_obs_url.text = RS.settings.obs_websocket_url
	%ln_obs_port.text = str(RS.settings.obs_websocket_port)
	%ln_obs_pass.text = RS.settings.obs_websocket_password

func _on_data_dir_pressed():
	OS.shell_open(RSSettings.data_dir)
func _on_btn_open_user_dir_pressed():
	OS.shell_open(OS.get_user_data_dir())

func _on_btn_reload_twitcher_pressed():
	RS.twitcher.connect_to_twitch()
func _on_btn_reload_commands_pressed():
	RS.custom.add_commands()

func _on_btn_open_cache_badges_dir_pressed():
	OS.shell_open(RS.settings.cache_badge)
func _on_btn_open_cache_emotes_dir_pressed():
	OS.shell_open(RS.settings.cache_emote)
func _on_btn_open_cache_cheer_emotes_dir_pressed():
	OS.shell_open(RS.settings.cache_cheermote)


func _on_btn_obs_connect_pressed():
	RS.no_obs_ws.connect_to_obsws(int(RS.settings.obs_websocket_port), RS.settings.obs_websocket_password)


func _on_btn_obs_req_api_pressed() -> void:
	OS.shell_open("https://github.com/obsproject/obs-websocket/blob/master/docs/generated/protocol.md#requests")


func _on_sl_window_scale_value_changed(value: float) -> void:
	%lb_window_scale.text = "x%s" % value


func _on_sl_window_scale_drag_ended(_value_changed: bool) -> void:
	get_tree().root.content_scale_factor = %sl_window_scale.value
	RS.settings.app_scale = %sl_window_scale.value


func _on_btn_obs_secret_pressed() -> void:
	%ln_obs_pass.secret = !%ln_obs_pass.secret
func _on_ln_obs_pass_text_changed(new_text: String) -> void:
	RS.settings.obs_websocket_password = new_text
func _on_ln_obs_port_text_changed(new_text: String) -> void:
	RS.settings.obs_websocket_port = int(new_text)
func _on_ln_obs_url_text_changed(new_text: String) -> void:
	RS.settings.obs_websocket_url = new_text
