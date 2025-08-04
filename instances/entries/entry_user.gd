extends PanelContainer
class_name RSTwitchUserEntry

var user: RSUser

var tw_hidden: Tween
var is_expanded: bool = false

signal user_selected(user: RSUser)


func _ready() -> void:
	update()
	toggle_buttons(false)
	%pnl_delete.hide()
	RS.user_mng.live_streamers_updated.connect(_on_live_streamers_updated)
	RS.user_mng.user_updated.connect(_on_user_updated)


#region Update
func update() -> void:
	if not user:
		push_error("No user for button.")
		return
	%btn_user.text = user.display_name
	%btn_shoutout.disabled = !user.is_streamer
	%btn_promote.disabled = user.promotion_description == ""
	%btn_special.disabled = user.custom_action == ""
	%user_live_rect.visible = user.user_id in RS.user_mng.live_streamers_data.keys()
	
	for rect: Control in %hb_games_count.get_children():
		rect.free()
	for i: int in user.steam_app_ids.size():
		var rect_steam: ColorRect = ColorRect.new()
		rect_steam.color = Color("3e7dc4")
		rect_steam.mouse_filter = Control.MOUSE_FILTER_IGNORE
		rect_steam.custom_minimum_size = Vector2.ONE * 4.0 # px
		%hb_games_count.add_child(rect_steam)
	for i: int in user.itchio_app_urls.size():
		var rect_itchio: ColorRect = ColorRect.new()
		rect_itchio.color = Color("fa5c5b")
		rect_itchio.mouse_filter = Control.MOUSE_FILTER_IGNORE
		rect_itchio.custom_minimum_size = Vector2.ONE * 4.0 # px
		%hb_games_count.add_child(rect_itchio)
	
	%user_pic.texture = await RS.loader.load_texture_from_url(user.profile_image_url)


func reload_profile_pic() -> void:
	%user_pic.texture = await RS.loader.load_texture_from_url(user.profile_image_url, false)


func reload_all_info_from_twitch() -> void:
	var t_user: TwitchUser = await RS.user_mng.get_t_user_from_twitch_api(user.user_id)
	if not t_user:
		_on_btn_delete_pressed()
		return
	user.update_from_twitch_user(t_user)
	RS.user_mng.save_user(user)
	update()
	reload_profile_pic()


func toggle_buttons(toggle_on: bool) -> void:
	const ANIM_SPEED = 0.2
	const MIN_SIZE = Vector2(32, 32)
	if tw_hidden:
		tw_hidden.kill()
	tw_hidden = create_tween()
	tw_hidden.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
	var min_size: Vector2 = MIN_SIZE if toggle_on else Vector2.ZERO
	var cover_btn_alpha: float = float(!toggle_on)
	var btns_alpha: float = float(toggle_on)
	
	for btn: Button in %hb_menu.get_children():
		tw_hidden.parallel().tween_property(
			btn,
			^"custom_minimum_size",
			min_size,
			ANIM_SPEED
		)
		tw_hidden.parallel().tween_property(
			btn,
			^"modulate:a",
			btns_alpha,
			ANIM_SPEED
		)
	
	%btn_menu.show()
	tw_hidden.tween_property(%btn_menu, ^"modulate:a", cover_btn_alpha, ANIM_SPEED)
	if toggle_on:
		tw_hidden.tween_property(%btn_menu, ^"visible", false, ANIM_SPEED)
		is_expanded = true
		set_process(true)


func _process(_delta: float) -> void:
	# check mouse in pnl_toggle area
	if !is_expanded:
		set_process(false)
		return
	
	var m_pos: Vector2 = get_global_mouse_position()
	var is_inside: bool = %pnl_toggle.get_global_rect().has_point(m_pos)
	if is_inside:
		return
	
	toggle_buttons(false)
	is_expanded = false
	set_process(false)
#endregion


#region Signals
func _on_user_updated(_user: RSUser) -> void:
	if not user:
		return
	if _user.user_id != user.user_id:
		return
	user = _user
	update()
func _on_live_streamers_updated() -> void:
	var is_live: bool = user.user_id in RS.user_mng.live_streamers_data.keys()
	%user_live_rect.visible = is_live
	%btn_raid.disabled = !is_live
#endregion


#region Buttons
func _on_btn_open_streamer_page_pressed() -> void:
	OS.shell_open("https://www.twitch.tv/%s" % user.username)
	RS.pnl_settings.hide()
func _on_btn_user_pressed():
	user_selected.emit(user)
func _on_btn_shoutout_pressed():
	RS.shoutout_mng.add_shoutout(user)


func _on_btn_menu_mouse_entered() -> void:
	toggle_buttons(true)

func _on_btn_promote_pressed():
	RS.twitcher.chat(user.promotion_description)
func _on_btn_special_pressed():
	pass # Replace with function body.
func _on_btn_reload_pressed():
	reload_all_info_from_twitch()
func _on_btn_raid_pressed() -> void:
	RS.twitcher.raid( str(user.user_id) )

func _on_btn_delete_pressed() -> void:
	%pnl_delete.show()
func _on_btn_delete_confirm_pressed() -> void:
	RS.user_mng.delete_user(user)
	%pnl_delete.hide()
func _on_btn_delete_cancel_pressed() -> void:
	%pnl_delete.hide()
#endregion
