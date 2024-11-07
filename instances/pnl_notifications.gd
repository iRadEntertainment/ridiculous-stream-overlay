
extends PanelContainer

@onready var vb = %vb
@onready var sfx_notif = %sfx_notif


func start():
	show()
	if !RS.vetting.notification_queued.is_connected(append_vetting_reward):
		RS.vetting.notification_queued.connect(append_vetting_reward)
	for child in vb.get_children():
		child.queue_free()


func append_vetting_reward(callable : Callable, data: RSTwitchEventData, warnings: int):
	sfx_notif.play()
	var pack : PackedScene = preload("res://instances/notification_vetting_reward.tscn")
	var new_notif : RSNotificationVettingReward = pack.instantiate()
	#var new_notif : RSNotificationVettingReward = RSGlobals.notif_vetting_reward_pack.instantiate()
	new_notif.vetting = RS.vetting
	new_notif.callable = callable
	new_notif.data = data
	new_notif.warnings = warnings
	
	vb.add_child(new_notif)
	new_notif.add_to_group("UI")
	new_notif.start()
