extends Control
class_name RSPnlChat


const commands_string_format = {
	"ACTION": "[i]%s[/i]",
	"!rb": "[rainbow freq=1.0 sat=0.8 val=0.8]%s[/rainbow]",
	"!big": "[font_size=64]%s[/font_size]",
	"!small": "[font_size=12]%s[/font_size]",
	"!wave": "[wave amp=50.0 freq=5.0 connect=1]%s[/wave]",
	"!hl": "[bgcolor=ff0000][color=ffffff]%s[/color][/bgcolor]",
	"!pulse": "[pulse freq=1.0 color=ffffff40 ease=-2.0]%s[/pulse]",
	"!tornado": "[tornado radius=10.0 freq=1.0 connected=1]%s[/tornado]",
	"!shake": "[shake rate=20.0 level=5 connected=1]%s[/shake]",
	"!hd": "[bgcolor=21262e][color=21262e]%s[/color][/bgcolor]",
}

@export var max_display_messages: int = 200
var sprite_effect : SpriteFrameEffect


func start():
	if !RS.twitcher.received_chat_message.is_connected(_on_chat_message):
		RS.twitcher.received_chat_message.connect(_on_chat_message)
	%pnl_connect.start()
	%lb_channel.text = RS.settings.broadcaster_name
	clear_chat()


func clear_chat() -> void:
	for entry: EntryChatMessage in %vb_messages.get_children():
		entry.free()


var badge_id = 0
var emote_start : int = 0
var fl_first_chat_message := true

func _on_chat_message(t_message: TwitchChatMessage) -> void:
	#var message: String = t_message.message.text
	put_chat_entry(t_message)
	while %vb_messages.get_child_count() > max_display_messages:
		%vb_messages.get_child(0).free()
	
	await get_tree().process_frame
	%scroll_msg.scroll_vertical = %scroll_msg.get_v_scroll_bar().max_value
	


func put_chat_entry(t_message: TwitchChatMessage) -> void:
	var chat_entry: EntryChatMessage = preload("res://instances/entries/entry_chat_message.tscn").instantiate()
	chat_entry.t_message = t_message
	chat_entry.username_pressed.connect(_on_chat_entry_username_pressed)
	#if message.begins_with("!"):
		#if message.begins_with("!tts"):
			#pass
		#else:
			#return
	#put_chat(t_message)
	%vb_messages.add_child(chat_entry)


func format_msg(key, _msg) -> String:
	_msg = _msg.replacen(key+" ", "")
	_msg = _msg.strip_edges()
	return commands_string_format[key]%_msg

#region Function Signals
func _on_chat_entry_username_pressed(
			parent: EntryChatMessage,
			_t_message: TwitchChatMessage,
			user: RSUser,
		) -> void:
	%context_menu_chat.populate(user)
	var pop_under_rect: Rect2 = parent.get_global_rect()
	pop_under_rect.position.y += pop_under_rect.size.y
	%context_menu_chat.popup_on_parent(pop_under_rect)
#endregion


#region Inspector Signals
func _on_ln_msg_text_submitted(new_text: String) -> void:
	RS.twitcher.chat(new_text)
	%ln_msg.clear()
	await get_tree().process_frame
	%ln_msg.edit()
func _on_ln_announce_text_submitted(new_text: String) -> void:
	var key: String = %opt_announce_color.text
	var color: TwitchAnnouncementColor = TwitchAnnouncementColor.new(key)
	RS.twitcher.announcement(new_text, color)
	%ln_announce.clear()


func _on_btn_close_pressed() -> void:
	hide()
#endregion
