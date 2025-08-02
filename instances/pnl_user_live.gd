extends PanelContainer
class_name PnlUserLive


var live_data: TwitchStream
var _t_user: TwitchUser


func _ready() -> void:
	clear()


func populate(_live_data: TwitchStream) -> void:
	live_data = _live_data
	set_process(live_data != null)
	_toggle_buttons(live_data != null)
	if not live_data: return
	_t_user = await RS.twitcher.service.get_user_by_id(live_data.user_id)
	
	%btn_stream_title.text = live_data.title
	%lb_stream_viewer_count.text = str(live_data.viewer_count)
	var thumbnail_url = live_data.thumbnail_url.format({"width": 640, "height": 360})
	%tex_stream_thumbnail.texture = await RS.loader.load_texture_from_url(thumbnail_url, false)


func clear() -> void:
	_toggle_buttons(false)
	%btn_stream_title.text = "Stream title"
	%tex_stream_thumbnail.texture = null
	%ln_chat_live_streamer.clear()
	%lb_stream_time.text = "--:--:--"
	%lb_stream_viewer_count.text = "0"


func _toggle_buttons(val: bool) -> void:
	%btn_stream_title.disabled = !val
	%btn_raid_current.disabled = !val
	%ln_chat_live_streamer.editable = val


#region Process
var ticks := 0
func _process(_delta: float) -> void:
	if not live_data:
		set_process(false)
		return
	
	ticks += 1
	if ticks < 30: return
	ticks = 0
	
	var system_unix = Time.get_unix_time_from_system()
	var stream_start_unix = Time.get_unix_time_from_datetime_string(live_data.started_at)
	var time_elapsed_string = Time.get_datetime_string_from_unix_time((system_unix - stream_start_unix), true)
	
	%lb_stream_time.text = time_elapsed_string.split(" ")[1]
#endregion


#region Signals MOVE TO PANEL LIVE
func _on_btn_raid_current_pressed():
	if not live_data: return
	RS.twitcher.raid(live_data.user_id)
	RS.pnl_settings.hide()


func _on_btn_stream_title_pressed() -> void:
	if not live_data: return
	OS.shell_open("https://www.twitch.tv/%s" % live_data.user_login)
	RS.pnl_settings.hide()


func _on_ln_chat_live_streamer_text_submitted(new_text: String) -> void:
	%ln_chat_live_streamer.clear()
	%ln_chat_live_streamer.edit()
	if !_t_user: return
	RS.twitcher.service.chat(new_text, _t_user)
#endregion
