extends PopupMenu
class_name ContextMenuChat

const Items: Dictionary = {
	"Mod": 1,
	"UnMod": 2,
	"Shoutout": 3,
	"OpenTwitchPage": 4,
}
var user: RSUser


func _ready() -> void:
	hide()


func populate(_user: RSUser) -> void:
	user = _user
	clear(true)
	add_icon_item(preload("res://ui/sprites/sword-brandish.svg"), "New mod!", Items.Mod)
	add_icon_item(preload("res://ui/icons/sword.png"), "Un-mod!", Items.UnMod)
	add_icon_item(preload("res://ui/icons/bootstrap_icons/megaphone-fill.svg"), "Shoutout!", Items.Shoutout)
	add_icon_item(preload("res://ui/icons/bootstrap_icons/display.svg"), "Open Twitch page", Items.OpenTwitchPage)
	
	for index: int in item_count:
		set_item_icon_max_width(index, 24)


func _on_id_pressed(id: int) -> void:
	match id:
		Items.Mod: RS.twitcher.api.add_channel_moderator(str(user.user_id), RS.settings.broadcaster_id)
		Items.UnMod: RS.twitcher.api.remove_channel_moderator(str(user.user_id), RS.settings.broadcaster_id)
		Items.Shoutout: RS.twitcher.service.shoutout(user.to_twitch_user())
		Items.OpenTwitchPage: OS.shell_open("https://twitch.tv/%s" % user.username)
