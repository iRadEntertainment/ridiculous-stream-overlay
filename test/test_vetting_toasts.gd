extends SceneTree
## Isolate APPDATA at res://.godot/toast-test-data before running.

var checks := 0
var failures := 0
var accepted := 0

func _initialize() -> void:
	_run.call_deferred()

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("VETTING TOAST FAIL: " + message)

func settle() -> void:
	for i in range(6):
		await process_frame

func enqueue(vetting, number: int) -> void:
	var data = load("res://classes/RSTwitchEventData.gd").new()
	data.username = "local_toast_test"
	data.reward_title = "Offline reward %d" % number
	data.user_input = "Local notification test. No Twitch action."
	vetting.custom_rewards_vetting(func(_data): accepted += 1, data)

func _run() -> void:
	var test_root = ProjectSettings.globalize_path("res://.godot/toast-test-data")
	if not OS.get_user_data_dir().replace("\\", "/").begins_with(test_root + "/"):
		push_error("Run with isolated APPDATA at " + test_root)
		quit(2)
		return
	var services = root.get_node("RS")
	# Keep RSMain out of the tree: never start Twitch, OBS or native click-through.
	var main = load("res://RSMain.gd").new()
	main.size = Vector2(1200, 675)
	var host := Control.new()
	host.size = main.size
	host.theme = load("res://ui/ridiculous_stream_main.theme")
	root.add_child(host)
	# Use the actual main scene's panel overrides without starting the whole overlay.
	var state = load("res://rs_main.tscn").get_state()
	var panel
	for index in range(state.get_node_count()):
		if state.get_node_name(index) == &"pnl_notifications":
			panel = state.get_node_instance(index).instantiate()
			for property in range(state.get_node_property_count(index)):
				panel.set(state.get_node_property_name(index, property), state.get_node_property_value(index, property))
	check(panel != null, "main scene notification panel found")
	if panel == null:
		quit(1)
		return
	host.add_child(panel)
	var vetting = load("res://classes/RSVetting.gd").new()
	root.add_child(vetting)
	panel.start(vetting)
	panel.sfx_notif.volume_db = -80.0
	var tracker = load("res://classes/RSMouseTracker.gd").new()
	root.add_child(tracker)
	await settle()
	check(panel.vb.get_child_count() == 0, "editor placeholders removed")
	check(not tracker.is_m_pos_in_control_nodes(Vector2(1100, 600)), "empty panel does not block")
	enqueue(vetting, 1)
	await settle()
	check(panel.vb.get_child_count() == 1, "real vetting signal creates a toast")
	var toast = panel.vb.get_child(0)
	var scroll: ScrollContainer = panel.get_node("scroll")
	check(panel.size.y == host.size.y, "production panel has full viewport height")
	check(toast.is_visible_in_tree(), "toast is visible in the tree")
	check(scroll.get_global_rect().encloses(toast.get_global_rect()), "toast is inside its clipping rectangle")
	check(is_equal_approx(toast.get_global_rect().end.y, host.size.y), "single toast sits at bottom")
	check(is_equal_approx(toast.get_global_rect().end.x, host.size.x), "single toast sits at right edge")
	var point: Vector2 = toast.get_global_rect().get_center()
	check(tracker.is_m_pos_in_control_nodes(point), "visible toast blocks mouse")
	check(not tracker.is_m_pos_in_control_nodes(Vector2(point.x, 10)), "blank space above toast passes mouse")
	toast.hide()
	check(not tracker.is_m_pos_in_control_nodes(point), "hidden toast passes mouse")
	toast.show()
	panel.modulate.a = 0.0
	check(not tracker.is_m_pos_in_control_nodes(point), "transparent ancestor passes mouse")
	panel.modulate.a = 1.0
	# Recreate the original zero-height clipping failure on purpose.
	panel.anchor_bottom = 0.0
	panel.offset_bottom = 0.0
	await settle()
	check(scroll.size.y == 0.0, "original zero-height condition reproduced")
	check(not tracker.is_m_pos_in_control_nodes(toast.get_global_rect().get_center()), "fully clipped toast passes mouse even when visible=true")
	panel.anchor_bottom = 1.0
	await settle()
	for i in range(2, 11):
		enqueue(vetting, i)
	await settle()
	var newest = panel.vb.get_child(-1)
	check(panel.vb.get_child_count() == 10, "burst retains all ten pending requests")
	check(scroll.scroll_vertical > 0, "overflow scrolls to newest toast")
	check(is_equal_approx(newest.get_global_rect().end.y, host.size.y), "newest toast remains at bottom after overflow")
	check(scroll.get_global_rect().encloses(newest.get_global_rect()), "newest toast is fully within clipping area")
	check(tracker.is_m_pos_in_control_nodes(scroll.get_v_scroll_bar().get_global_rect().get_center()), "visible scrollbar blocks mouse")
	scroll.scroll_vertical = 0
	await settle()
	check(scroll.scroll_vertical == 0, "manual scrolling to older requests remains possible")
	for viewport_size in [Vector2(800, 450), Vector2(1600, 900)]:
		host.size = viewport_size
		main.size = viewport_size
		await settle()
		check(is_equal_approx(panel.get_global_rect().end.x, host.size.x), "panel follows resized right edge")
		check(is_equal_approx(newest.get_global_rect().end.y, host.size.y), "toast follows resized bottom edge")
	# A nonzero, partial clipping rectangle within the window must also be respected.
	panel.anchor_bottom = 0.0
	panel.offset_bottom = 200.0
	await settle()
	scroll.scroll_vertical = 0
	await settle()
	var clipped_toast = panel.vb.get_child(2)
	point = clipped_toast.get_global_rect().get_center()
	check(main.get_rect().has_point(point) and not scroll.get_global_rect().has_point(point), "clipped toast rectangle lies inside window but outside scroll")
	check(not tracker.is_m_pos_in_control_nodes(point), "scrolled-out toast cannot block outside scroll")
	panel.anchor_bottom = 1.0
	panel.offset_bottom = 0.0
	await settle()
	newest.get_node("vb/hb/btns/btn_accept").pressed.emit()
	await settle()
	check(accepted == 1 and panel.vb.get_child_count() == 9, "accept button calls callback once and dismisses toast")
	for child in panel.vb.get_children():
		child.queue_free()
	await settle()
	check(not tracker.is_m_pos_in_control_nodes(Vector2(host.size.x - 80, host.size.y - 50)), "dismissed toasts leave no blocking area")
	host.free()
	vetting.free()
	tracker.free()
	main.free()
	services.main = null
	print("VETTING TOASTS: ", checks, " checks, ", failures, " failures")
	quit(failures)
