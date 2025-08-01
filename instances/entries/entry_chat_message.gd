extends PanelContainer
class_name EntryChatMessage

var pnl_chat: RSPnlChat
var t_message: TwitchChatMessage
var user: RSUser

var is_read: bool = false:
	set(val):
		is_read = val
		if !is_node_ready(): await ready
		%pnl_is_read.visible = not is_read


func _ready() -> void:
	if not t_message:
		return
	user = await RS.user_mng.get_any_user_from_user_id(t_message.chatter_user_id.to_int())
	populate()


func populate() -> void:
	%lb_username.text = t_message.chatter_user_name
	%lb_username.add_theme_color_override(&"font_color", Color(t_message.get_color()))
	
	#region Badges
	# Clear badges from container
	for child in %hb_badges.get_children():
		child.queue_free()
	# Get all badges from the user that sends the t_message
	var badges_dict: Dictionary = await t_message.get_badges(RS.twitcher.service.media_loader)
	var badges: Array[SpriteFrames] = []
	badges.assign(badges_dict.values())
	# Add all badges
	for badge: SpriteFrames in badges:
		#result_message += "[sprite id='b-%s']%s[/sprite]" % [badge_id, badge.resource_path]
		#badge_id += 1
		var text_rect := TextureRect.new()
		text_rect.texture = badge.get_frame_texture(&"default", 0)
		text_rect.custom_minimum_size = Vector2.ONE * 24
		text_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		text_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		text_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		%hb_badges.add_child(text_rect)
	#endregion
	
	#region Message FX
	var result_message: String = ""
	# Show different effects depending on the t_message types
	match t_message.message_type:
		# The default t_message style
		TwitchChatMessage.MessageType.text:
			result_message = await prepare_message_fragments(t_message, result_message)
		# When someone is using the gigantified emotes
		TwitchChatMessage.MessageType.power_ups_gigantified_emote:
			result_message = await prepare_message_fragments(t_message, result_message, 3)
		# When someone is using the highlight my t_message from the channel point rewards
		TwitchChatMessage.MessageType.channel_points_highlighted:
			result_message += "[bgcolor=#755ebc][color=#e9fffb]"
			result_message = await prepare_message_fragments(t_message, result_message)
			result_message += "[/color][/bgcolor]"
		# When someone is using the t_message effect bit reward
		TwitchChatMessage.MessageType.power_ups_message_effect:
			result_message += "[shake rate=20.0 level=5 connected=1]"
			result_message = await prepare_message_fragments(t_message, result_message)
			result_message += "[/shake]"
	#endregion
	
	#region Prepare and apply text
	var sprite_effect: SpriteFrameEffect = %lb_msg.custom_effects[0]
	result_message = sprite_effect.prepare_message(result_message, %lb_msg)
	%lb_msg.text = result_message
	#endregion


#region Twitcher Utilities
## Prepares the message so that all fragments will be shown correctly
func prepare_message_fragments(message: TwitchChatMessage, current_text: String, emote_scale: int = 1) -> String:
	# Load emotes and badges in parallel to improve the speed
	await message.load_emotes_from_fragment(RS.twitcher.service.media_loader)
	# Unique Id for the spriteframes to identify them
	var fragment_id: int = 0
	for fragment: TwitchChatMessage.Fragment in message.message.fragments:
		fragment_id += 1
		match fragment.type:
			TwitchChatMessage.FragmentType.text:
				current_text += fragment.text
			TwitchChatMessage.FragmentType.cheermote:
				var cheermote_scale: StringName = TwitchCheermoteDefinition.SCALE_MAP.get(emote_scale, TwitchCheermoteDefinition.SCALE_1)
				var cheermote: SpriteFrames = await fragment.cheermote.get_sprite_frames(RS.twitcher.service.media_loader, cheermote_scale)
				current_text += "[sprite id='f-%s']%s[/sprite]" % [fragment_id, cheermote.resource_path]
			TwitchChatMessage.FragmentType.emote:
				var emote: SpriteFrames = await fragment.emote.get_sprite_frames(RS.twitcher.service.media_loader, emote_scale)
				current_text += "[sprite id='f-%s']%s[/sprite]" % [fragment_id, emote.resource_path]
			TwitchChatMessage.FragmentType.mention:
				current_text += "[color=%s]@%s[/color]" % ["#00a0b6", fragment.mention.user_name]
	return current_text


# Formats the time to 02:03
func _get_time() -> String:
	var time_data: Dictionary = Time.get_time_dict_from_system()
	return "%02d:%02d" % [time_data["hour"], time_data["minute"]]
#endregion


#region Signals
func _on_lb_msg_meta_clicked(meta: Variant) -> void:
	OS.shell_open(meta)
	RS.pnl_chat.hide()


func _on_controls_combined_event_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index != MOUSE_BUTTON_LEFT:
			return
		if not is_read: is_read = true
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if not is_read: is_read = true


func _on_pnl_is_read_gui_input(event: InputEvent) -> void:
	_on_controls_combined_event_input(event)

func _on_lb_msg_gui_input(event: InputEvent) -> void:
	_on_controls_combined_event_input(event)
#endregion
