
extends Control
class_name RSPnlChat

@onready var ln_msg : LineEdit = %ln_msg
@onready var ln_announce : LineEdit = %ln_announce
@onready var opt_announce_color = %opt_announce_color
@onready var lb_chat : RichTextLabel = %lb_chat
@onready var pnl_connect : PanelContainer = %pnl_connect

const commands_string_format = {
	"ACTION": "[i]%s[/i]",
	"!rb": "[rainbow freq=1.0 sat=0.8 val=0.8]%s[/rainbow]",
	"!big" : "[font_size=64]%s[/font_size]",
	"!small" : "[font_size=12]%s[/font_size]",
	"!wave" : "[wave amp=50.0 freq=5.0 connect=1]%s[/wave]",
	"!hl" : "[bgcolor=ff0000][color=ffffff]%s[/color][/bgcolor]",
	"!pulse" : "[pulse freq=1.0 color=ffffff40 ease=-2.0]%s[/pulse]",
	"!tornado" : "[tornado radius=10.0 freq=1.0 connected=1]%s[/tornado]",
	"!shake" : "[shake rate=20.0 level=5 connected=1]%s[/shake]",
	"!hd" : "[bgcolor=21262e][color=21262e]%s[/color][/bgcolor]",
}

var sprite_effect : SpriteFrameEffect


func start():
	if !RS.settings.chatbot_channel:
		return
	if !RS.twitcher.received_chat_message.is_connected(_on_chat_message):
		RS.twitcher.received_chat_message.connect(_on_chat_message)
	sprite_effect = SpriteFrameEffect.new()
	lb_chat.install_effect(sprite_effect)
	pnl_connect.start()
	%lb_channel.text = RS.settings.chatbot_channels.front()


var badge_id = 0
var emote_start : int = 0
var fl_first_chat_message := true

func _on_chat_message(_channel: String, from_user: String, message: String, tags: TwitchTags.PrivMsg):
	if message.begins_with("!"):
		if message.begins_with("!tts"):
			pass
		else:
			return
	var username = from_user.to_lower()
	put_chat(username, message, tags)


func put_chat(username: String, message: String, _tags: TwitchTags.PrivMsg):
	var tags := TwitchTags.Message.from_priv_msg(_tags)
	# var badges = await tags.get_badges() as Array[SpriteFrames];
	# var emotes = await tags.get_emotes() as Array[TwitchIRC.EmoteLocation];
	var color = tags.get_color();
	if color.is_empty():
		color = RSGlobals.DEFAULT_RIGID_LABEL_COLOR
	
	if _tags.display_name == "IAmAMerlin":
		color = Color.BROWN.to_html()
	var user : RSUser = await RS.user_mng.get_user_from_username(username)
	if user:
		if user.custom_chat_color != Color.BLACK:
			color = user.custom_chat_color.to_html()
	
	if !fl_first_chat_message:
		lb_chat.newline()
	fl_first_chat_message = false

	var result_message = ""
	for key in commands_string_format.keys():
		if message.find(key) != -1:
			message = format_msg(key, message)
	
	# The sprite effect needs unique ids for every sprite that it manages
	# Add all badges to the message
	#badge_id = 0
	#for badge: SpriteFrames in badges:
		#result_message += "[sprite id='b-%s']%s[/sprite]" % [badge_id, badge.resource_path];
		#badge_id += 1;
	
	result_message += "[b][color=%s]%s[/color][/b]: " % [color, _tags.display_name];

	# Replace all the emoji names with the appropriate emojis
	# Tracks the start where to replace next
	#emote_start = 0
	#for emote in emotes:
		## Takes text between the start / the last emoji and the next emoji
		#var part := message.substr(emote_start, emote.start - emote_start);
		## Adds this text to the message
		#result_message += part;
		## Adds the sprite after the text
		#result_message += "[sprite id='%s']%s[/sprite]" % [badge_id, emote.sprite_frames.resource_path];
		## Marks the start of the next text
		#emote_start = emote.end + 1;
		##badge_id += 1;
				  #
	## get the text between the last emoji and the end
	#var part := message.substr(emote_start, message.length() - emote_start);
	## adds it to the message
	#result_message += part;
	## adds all the emojis to the richtext and registers them to be processed
	#result_message = sprite_effect.prepare_message(result_message, lb_chat);
	
	lb_chat.append_text(result_message + message)
	lb_chat.pop_all()


func format_msg(key, _msg) -> String:
	_msg = _msg.replacen(key+" ", "")
	_msg = _msg.strip_edges()
	return commands_string_format[key]%_msg


func change_font_size(font_size : int):
	theme.set("RichTextLabel/font_sizes/bold_font_size", font_size)
	theme.set("RichTextLabel/font_sizes/bold_italics_font_size", font_size)
	theme.set("RichTextLabel/font_sizes/italics_font_size", font_size)
	theme.set("RichTextLabel/font_sizes/mono_font_size", font_size)
	theme.set("RichTextLabel/font_sizes/normal_font_size", font_size)
func _on_ln_msg_text_submitted(new_text):
	RS.twitcher.chat(new_text)
	ln_msg.clear()
func _on_ln_announce_text_submitted(new_text):
	var color : String = opt_announce_color.get_item_text( opt_announce_color.get_selected_id() )
	RS.twitcher.announcement(new_text, color)
	ln_announce.clear()


func _on_sl_font_size_value_changed(value):
	change_font_size(value as int)
	%lb_font_size.text = str(value)


func _on_btn_close_pressed() -> void:
	hide()
