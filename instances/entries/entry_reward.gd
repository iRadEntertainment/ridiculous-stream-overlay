extends PanelContainer
class_name EntryReward


enum Type {TWITCH, LOCAL, NEW}

var reward: TwitchCustomReward
var type: Type
var local_icon_filepath: String

signal pressed(entry: EntryReward)


func _ready() -> void:
	if not reward:
		return
	var style_box: StyleBoxFlat = get("theme_override_styles/panel").duplicate()
	style_box.bg_color = Color(reward.background_color)
	set("theme_override_styles/panel", style_box)
	%lb_title.text = reward.title
	%lb_cost.text = str(reward.cost)
	%ck_is_active.visible = type == Type.TWITCH
	%ck_is_active.visible = type == Type.TWITCH
	if type == Type.TWITCH:
		%ck_is_active.button_pressed = reward.is_enabled
		if reward.image:
			%icon.url = reward.image.url_4x
			%icon.load_from_url()
	elif local_icon_filepath:
		%icon.texture = load(local_icon_filepath)


func _update_on_twitch() -> void:
	var body := TwitchUpdateCustomReward.Body.create()
	body.is_enabled = reward.is_enabled
	body.title = reward.title
	#return
	# TODO: The following request never returns from await (Unauth, refresh token)
	var request: TwitchUpdateCustomReward.Response = await RS.twitcher.api.update_custom_reward(body, reward.id, RS.settings.broadcaster_id)
	print(request.response.response_data)
	if request.response.result != HTTPRequest.RESULT_SUCCESS:
		print("Cannot update twitch reward %s. Error:\n%s" % [reward.title, request.response.response_data])


func _on_ck_is_active_toggled(toggled_on) -> void:
	if toggled_on == reward.is_enabled: return
	reward.is_enabled = toggled_on
	_update_on_twitch()


func _on_btn_pressed() -> void:
	pressed.emit(self)
