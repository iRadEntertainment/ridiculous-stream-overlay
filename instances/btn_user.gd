extends HBoxContainer
class_name RSTwitchUserEntry

var user: RSTwitchUser

@onready var user_pic = $user_pic
@onready var btn_user = $btn_user
@onready var btn_shoutout = $btn_shoutout
@onready var btn_promote = $btn_promote
@onready var btn_special = $btn_special
@onready var btn_reload = $btn_reload
@onready var user_live_rect = $btn_user/user_live_rect

signal user_selected(user: RSTwitchUser)

func _ready() -> void:
	update()
	RS.user_mng.live_streamers_updated.connect(_on_live_streamers_updated)
	RS.user_mng.user_updated.connect(_on_user_updated)


func update() -> void:
	btn_user.text = user.display_name
	btn_shoutout.disabled = !user.is_streamer
	btn_promote.disabled = user.promotion_description == ""
	btn_special.disabled = user.custom_action == ""
	user_live_rect.visible = user.user_id in RS.user_mng.live_streamers_data.keys()
	user_pic.texture = await RS.loader.load_texture_from_url(user.profile_image_url)


func reload_profile_pic():
	user_pic.texture = await RS.loader.load_texture_from_url(user.profile_image_url, false)


func _on_user_updated(_user: RSTwitchUser) -> void:
	if _user.user_id != user.user_id:
		return
	user = _user
	update()
func _on_live_streamers_updated() -> void:
	user_live_rect.visible = user.user_id in RS.user_mng.live_streamers_data.keys()
func _on_btn_user_pressed():
	user_selected.emit(user)
func _on_btn_shoutout_pressed():
	RS.shoutout_mng.add_shoutout(user)
func _on_btn_promote_pressed():
	RS.twitcher.chat(user.promotion_description)
func _on_btn_special_pressed():
	pass # Replace with function body.
func _on_btn_reload_pressed():
	reload_profile_pic()


func _on_btn_open_streamer_page_pressed() -> void:
	OS.shell_open("https://www.twitch.tv/%s" % user.username)
