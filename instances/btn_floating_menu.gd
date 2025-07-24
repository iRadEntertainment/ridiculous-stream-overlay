extends RSSubMenuButton
class_name RSFloatingMenu

const COL_ON := Color.LIGHT_GREEN
const COL_OFF := Color.LIGHT_SALMON

@onready var btn_panels: Button = %btn_panels
@onready var indicators: Control = %indicators
@onready var ico_mic: TextureRect = %ico_mic
@onready var ico_brave: TextureRect = %ico_brave
@onready var ico_stream: TextureRect = %ico_stream
@onready var ico_pixelate: TextureRect = %ico_pixelate

var is_anchored := true
var anchored_position: Vector2


func start(_main_menu_button: RSSubMenuButton = null) -> void:
	anchored_position = position
	var _parent : Control = get_parent()
	_parent.resized.connect(func(): calculate_anchored_pos(); is_anchored = false)
	generate_panels_buttons()
	super(self)
	start_indicators()
	if RS.physic_scene:
		RS.physic_scene.count_updated.connect(update_obj_count)
	%btn_close.visibility_changed.connect(func(): print_stack())

func start_indicators() -> void:
	if !RS.no_obs_ws:
		return
	RS.no_obs_ws.scenes_updated.connect(
	func():
		ico_mic.modulate = COL_OFF if RS.no_obs_ws.is_mic_muted else COL_ON
		ico_brave.modulate = COL_OFF if RS.no_obs_ws.is_brave_muted else COL_ON
		ico_stream.modulate = COL_ON if RS.no_obs_ws.is_stream_on else COL_OFF
		ico_pixelate.modulate = COL_ON if RS.no_obs_ws.is_pixelate_on else COL_OFF
	)
	
	var tot = indicators.get_child_count()
	for i in tot:
		var ind : TextureRect = indicators.get_child(i)
		ind.show()
		ind.position = (size/2 - ind.size/2)
		ind.position += Vector2.from_angle(TAU*i/tot + PI/2) * (size.x/2 - ind.size.x/2)
	
	ico_mic.modulate = COL_OFF if RS.no_obs_ws.is_mic_muted else COL_ON
	ico_brave.modulate = COL_OFF if RS.no_obs_ws.is_brave_muted else COL_ON
	ico_stream.modulate = COL_ON if RS.no_obs_ws.is_stream_on else COL_OFF

func generate_panels_buttons() -> void:
	if !RS.is_node_ready():
		await RS.ready
	for pnl: Control in RS.pnls_to_start:
		var btn := Button.new()
		btn.focus_mode = Control.FOCUS_NONE
		btn.text = pnl.name.lstrip("pnl_").left(3)
		btn.pressed.connect(func(): pnl.visible = !pnl.visible)
		btn_panels.add_child(btn)
	for btn in get_children():
		btn.custom_minimum_size = MIN_SIZE
		btn.add_to_group("UI")


func update_obj_count(val: int) -> void:
	%lb_count.visible = (val != 0)
	%lb_count.text = str(val)


func _process(d: float) -> void:
	super(d)
	if not is_anchored and not is_dragged:
		position = position.lerp(anchored_position, d*10)
		if position.distance_squared_to(anchored_position) < 1:
			position = anchored_position
			is_anchored = true

func _on_gui_input(event: InputEvent) -> void:
	super(event)
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if not event.is_pressed():
				is_anchored = false
				calculate_anchored_pos()
	if event is InputEventMouseMotion and is_mouse_click_down:
		if is_open:
			expand_menu(false)


func calculate_anchored_pos():
	#var m_pos := get_global_mouse_position()
	var m_pos := global_position + size/2.0
	var w_size := get_window().size / get_tree().root.content_scale_factor
	# find the closest edge first
	if min(m_pos.x, abs(w_size.x - m_pos.x)) < min(m_pos.y, abs(w_size.y - m_pos.y)):
		closest_edge = Edge.LEFT if m_pos.x < abs(w_size.x - m_pos.x) else Edge.RIGHT
	else:
		closest_edge = Edge.UP if m_pos.y < abs(w_size.y - m_pos.y) else Edge.BOT
	# find the anchor position
	match closest_edge:
		Edge.UP:
			anchored_position = Vector2(position.x, 0)
			parent_dir = Vector2.DOWN
		Edge.RIGHT:
			anchored_position = Vector2(w_size.x - size.x, position.y)
			parent_dir = Vector2.LEFT
		Edge.BOT:
			anchored_position = Vector2(position.x, w_size.y - size.y)
			parent_dir = Vector2.UP
		Edge.LEFT:
			anchored_position = Vector2(0, position.y)
			parent_dir = Vector2.RIGHT
	
	anchored_position = anchored_position.clamp(Vector2(), Vector2(w_size)-size)

#region Physics Signals
func _on_btn_beans_pressed() -> void: RS.custom.beans("")
func _on_btn_laser_pressed() -> void: RS.custom.laser()
func _on_btn_nuke_pressed() -> void: RS.physic_scene.nuke()
func _on_btn_zerog_pressed() -> void: RS.custom.zero_g()
func _on_btn_names_pressed() -> void: RS.custom.destructibles_names()
func _on_btn_granade_pressed() -> void: RS.physic_scene.spawn_grenade()
#endregion


#region Panels Signals
func _on_btn_chat_pressed() -> void:
	RS.pnl_chat.visible = !RS.pnl_chat.visible
func _on_btn_user_list_pressed() -> void:
	RS.pnl_settings.open_tab(1)
	RS.pnl_settings.visible = !RS.pnl_settings.visible
#endregion


#region End Stream Signals
func _on_btn_close_pressed() -> void:
	RS.quit()
func _on_btn_summary_pressed() -> void:
	RS.pnl_summary.visible = !RS.pnl_summary.visible
#endregion
#func _on_btn_spam_form_pressed() -> void:
	#RS.twitcher.chat("Person, you have been invited to join the coolest team https://www.twitch.tv/team/indiegamedevs on Twitch. Compile this form to get an invitation link. Remember that when you get the link: you need to go to Creator Dashboard > Settings > Channel > Featured Content > scroll all the way to the bottom. Here is the form link https://forms.gle/bU2WXAYfoZyVpwWW9")
	#OS.shell_open("https://www.twitch.tv/team/indiegamedevs")
#region OBS Signals
func _on_btn_cig_pressed() -> void:
	RS.custom.suggest_no_ads()
	RS.custom.toggle_cig_overlay()
func _on_btn_mic_pressed() -> void:
	RS.no_obs_ws.toggle_mic_mute()
func _on_btn_brave_sound_pressed() -> void:
	RS.no_obs_ws.toggle_brave_mute()
func _on_btn_pixelate_pressed() -> void:
	var source_name = "main_desk"
	var filter_name = "Blur"
	RS.no_obs_ws.is_pixelate_on = !RS.no_obs_ws.is_pixelate_on
	RS.no_obs_ws.set_item_filter_enabled(source_name, filter_name, RS.no_obs_ws.is_pixelate_on)
#endregion


#region Settings Signals
func _on_btn_debug_pressed() -> void:
	RS.debug_view.visible = !RS.debug_view.visible


func _on_btn_maximize_pressed() -> void:
	RS.display.set_borderless_maximized(!RS.display.is_maximized)


func _on_btn_test_pressed() -> void:
	var param := RSBeansParam.new()
	param.img_paths = ["can.png"]
	param.sfx_paths = [
			"sfx_can_01.ogg",
			"sfx_can_02.ogg",
			"sfx_can_03.ogg",
			"sfx_can_04.ogg",
		]
	param.scale = 0.2
	
	param.spawn_count_min = 5
	param.spawn_count_max = 200
	param.is_pickable = true
	param.is_destroy = true
	
	#param.destroy_shard_params
	
	
	RS.physic_scene.add_image_bodies(param)
	
	
	#RS.alert_scene.wheel_of_random_raid()
	#var e_theme := EditorInterface.get_editor_theme()
	#ResourceSaver.save(e_theme, "res://godot_4_3.theme")
	#RS.twitcher.api.create_custom_rewards()
	
	#var res := await RS.twitcher.api.get_custom_reward([], false, str(RS.settings.broadcaster_id))
	#for reward : TwitchCustomReward in res.data:
		#if reward.image:
			#var icon_4 := await RS.loader.load_texture_from_url(reward.image.url_4x, false)
			#var icon_2 := await RS.loader.load_texture_from_url(reward.image.url_2x, false)
			#var icon_1 := await RS.loader.load_texture_from_url(reward.image.url_1x, false)
			#var save_name = "res://ui/rewards_icons/" + reward.title.validate_filename()
			#ResourceSaver.save(icon_4, save_name + "4.png")
			#ResourceSaver.save(icon_2, save_name + "2.png")
			#ResourceSaver.save(icon_1, save_name + "1.png")
	
	#var u = await RS.twitcher.get_teams_users("indiegamedevs")
	#print(u)
	#for username in u:
		#if not username.to_lower() in RS.user_mng.known.keys():
			#print(username)
	#var test_text = "{user} something {else}"
	#var prefix = "[color=#f00]"
	#var suffix = "[/color]"
	#var res = RSAlertOverlay.decorate_all_tags(test_text, prefix, suffix)
	#RS.twitcher.chat(res)
#endregion
