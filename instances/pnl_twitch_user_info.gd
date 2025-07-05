extends PanelContainer
class_name PnlTwitchUserInfo



func populate_from_twitch_user(user: TwitchUser) -> void:
	clear()
	if not user: return


func populate_from_rs_user(user: RSUser) -> void:
	clear()
	if not user: return
	


func clear() -> void:
	pass
