
extends PanelContainer

@onready var vb = %vb
@onready var sfx_notif = %sfx_notif
@onready var scroll: ScrollContainer = $scroll

var _vetting: RSVetting


func start(vetting: RSVetting = RS.vetting):
	if is_instance_valid(_vetting) and _vetting.notification_queued.is_connected(append_vetting_reward):
		_vetting.notification_queued.disconnect(append_vetting_reward)
	_vetting = vetting
	show()
	if !_vetting.notification_queued.is_connected(append_vetting_reward):
		_vetting.notification_queued.connect(append_vetting_reward)
	var scrollbar := scroll.get_v_scroll_bar()
	if not scrollbar.changed.is_connected(_scroll_to_bottom):
		scrollbar.changed.connect(_scroll_to_bottom)
	scrollbar.add_to_group("UI")
	for child in vb.get_children():
		child.queue_free()


func _scroll_to_bottom() -> void:
	# Range changes happen after container layout, including additions and resizes.
	scroll.scroll_vertical = int(scroll.get_v_scroll_bar().max_value)


func append_vetting_reward(callable : Callable, data: RSTwitchEventData, warnings: int):
	sfx_notif.play()
	var pack : PackedScene = preload("res://instances/notification_vetting_reward.tscn")
	var new_notif : RSNotificationVettingReward = pack.instantiate()
	new_notif.vetting = _vetting
	new_notif.callable = callable
	new_notif.data = data
	new_notif.warnings = warnings
	
	vb.add_child(new_notif)
	new_notif.add_to_group("UI")
	new_notif.start()
