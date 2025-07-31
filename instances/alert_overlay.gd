
extends Control
class_name RSAlertOverlay

const BAR_PACK = preload("res://instances/alert_bar.tscn")
const WHEEL_PACK = preload("res://instances/the_wheel_of_random.tscn")
const ACCENT_COLOUR = "#f737d0"
const PRE = "[color=%s][shake]" % ACCENT_COLOUR
const SUF = "[/shake][/color]"
const DURATION = 10.0


@onready var sfx_alert = %sfx_alert
@onready var vb_cnt: VBoxContainer = %vb_cnt


func _ready():
	set_process(false)

func start():
	hide()
	vb_cnt.child_entered_tree.connect(func(_n): visible = true)
	vb_cnt.child_exiting_tree.connect(func(_n): visible = vb_cnt.get_child_count() > 1)


func initialize_stop_streaming(user: RSUser, message: String) -> void:
	var bbcode := "{user} will forcefully end the strem in {sec_left} s\nbecause {message}."
	bbcode = RSAlertOverlay.decorate_all_tags(bbcode, PRE, SUF)
	bbcode = bbcode.format(
		{"user": user.display_name,
		"message": message})
	#var callable : Callable = (func(): print("Shut down activated") )
	var callable : Callable = RS.custom.stop_streaming
	instantiate_new_bar(bbcode, callable)


func initialize_raid(user: RSUser, to_user : RSUser, message: String = "") -> void:
	var bbcode := "{user} is starting a raid to {to_user}\nbecause {message}."
	bbcode = RSAlertOverlay.decorate_all_tags(bbcode, PRE, SUF)
	bbcode = bbcode.format(
		{"user": user.display_name,
		"to_user": to_user.display_name,
		"message": message,
		})
	var callable : Callable = RS.twitcher.raid.bind(str(to_user.user_id))
	instantiate_new_bar(bbcode, callable)


func wheel_of_random_raid(launched_by: RSUser, message: String = "") -> void:
	await RS.user_mng.refresh_live_streamers()
	var online: PackedStringArray = (RS.user_mng.known.keys())
	if online.is_empty():
		return
	var wheel: RSWheelOfRandom = WHEEL_PACK.instantiate()
	vb_cnt.add_child(wheel)
	wheel.start(online)
	wheel.winner_selected.connect(raid_selected_username.bind(launched_by, message))
func raid_selected_username(to_username: String, from_user: RSUser, message: String = "") -> void:
	var user_to_raid: RSUser = await RS.user_mng.get_any_user_from_username(to_username)
	initialize_raid(from_user, user_to_raid, message)


func instantiate_new_bar(bbcode: String, callable_with_bindings: Callable, duration := DURATION) -> void:
	sfx_alert.play()
	var new_bar := BAR_PACK.instantiate()
	vb_cnt.add_child(new_bar)
	new_bar.start(bbcode, callable_with_bindings, duration)
	show()

static func decorate_all_tags(text: String, prefix: String, suffix: String) -> String:
	var regex = RegEx.new()
	#regex.compile("\\{(.*?)\\}")
	regex.compile("\\{")
	text = regex.sub(text, prefix+"{", true)
	regex.compile("\\}")
	text = regex.sub(text, "}"+suffix, true)
	return text


#func _process(_d):
	#progress_time_left.value = tmr_progress.time_left
	#seconds_left.text = "%d"%tmr_progress.time_left
	#progress_time_left_raid.value = tmr_progress.time_left
