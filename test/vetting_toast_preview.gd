extends Control
## Run this scene with F6. No Twitch connection or persistent vetting decisions.

class PreviewVetting extends RSVetting:
	func save_user_vetting_list() -> void:
		pass

var vetting := PreviewVetting.new()
var sequence := 0
@onready var panel = $pnl_notifications
@onready var status: Label = $controls/status

func _ready() -> void:
	add_child(vetting)
	panel.start(vetting)
	$controls/add.pressed.connect(add_toast)
	$controls/batch.pressed.connect(func():
		for i in range(8):
			add_toast()
	)
	$controls/clear.pressed.connect(func():
		for toast in panel.vb.get_children():
			toast.queue_free()
	)
	# Let the editor placeholder notifications finish being removed first.
	await get_tree().process_frame
	add_toast()

func add_toast() -> void:
	sequence += 1
	var data := RSTwitchEventData.new()
	data.user_id = sequence
	data.username = "preview_user_%d" % sequence
	data.reward_title = "Preview reward %d" % sequence
	data.user_input = "Offline test: resize the window, add more toasts, or use any decision button."
	vetting.custom_rewards_vetting(func(_data):
		status.text = "Accepted preview reward %d (no live action)." % data.user_id,
		data)
