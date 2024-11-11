
extends PanelContainer


@onready var ln_broadcaster_id : LineEdit = %ln_broadcaster_id
@onready var btn_connect_at_startup = %btn_connect_at_startup


func start():
	visible = !RS.twitcher.is_connected_to_twitch
	if !RS.twitcher.connected_to_twitch.is_connected(hide):
		RS.twitcher.connected_to_twitch.connect(hide)
	ln_broadcaster_id.text = str(RS.settings.broadcaster_id)
	btn_connect_at_startup.button_pressed = RS.settings.auto_connect


func _on_btn_connect_twitcher_pressed():
	connect_to_twitch()

func _on_ln_broadcaster_id_text_submitted(_new_text:String):
	connect_to_twitch()

func _on_btn_retrieve_id_pressed():
	OS.shell_open("https://www.streamweasels.com/tools/convert-twitch-username-to-user-id/")

func _on_btn_connect_at_startup_toggled(toggled_on:bool):
	if toggled_on != RS.settings.auto_connect:
		RS.settings.auto_connect = toggled_on

func connect_to_twitch():
	RS.settings.broadcaster_id = ln_broadcaster_id.text
	RS.save_settings()
	RS.twitcher.connect_to_twitch()
