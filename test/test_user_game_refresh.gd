extends "res://test/test_user_games.gd"
## Same isolated APPDATA as test_user_games.gd; all network replies are controlled.

func wait_until(condition: Callable, message: String) -> void:
	var deadline := Time.get_ticks_msec() + 8000
	while not condition.call() and Time.get_ticks_msec() < deadline:
		await create_timer(0.01).timeout
	check(condition.call(), message)

func _run() -> void:
	var test_root = ProjectSettings.globalize_path("res://.godot/user-games-test-data")
	if not OS.get_user_data_dir().replace("\\", "/").begins_with(test_root + "/"):
		push_error("Run with isolated APPDATA at " + test_root)
		quit(2)
		return
	user_script = load("res://classes/RSUser.gd")
	steam_script = load("res://lib/games_info/SteamAppData.gd")
	itch_script = load("res://lib/games_info/ItchIOAppData.gd")
	var settings_script = load("res://classes/RSSettings.gd")
	settings_script.data_dir = test_root.path_join("refresh-%d" % Time.get_ticks_usec())
	var services = root.get_node("RS")
	var original_manager = services.user_mng
	manager = load("res://test/fixtures/user_games_manager.gd").new()
	root.add_child(manager)
	services.user_mng = manager
	var a = manager.observe_user(201, "refresh_a")
	var b = manager.observe_user(202, "refresh_b")
	for id in range(10, 14):
		a.steam_app_ids[id] = steam(id, "Cached %d" % id)
	for id in range(1, 4):
		var url = "https://fixture.itch.io/game%d" % id
		a.itchio_app_urls[url] = itch(url, "Cached itch %d" % id, id)
	b.steam_app_ids[50] = steam(50, "Cached B")
	manager.save_user(a)
	manager.save_user(b)
	var worker = manager.game_refresh
	var steam_api = fake_api(worker.get_node("SteamService"))
	var itch_api = fake_api(worker.get_node("ItchIOService"))
	steam_api.delayed = true
	itch_api.delayed = true
	for id in range(10, 14):
		steam_api.responses[id] = steam(id, "Fresh %d" % id)
	steam_api.responses[12] = null # Failure still counts as this launch's attempt.
	steam_api.responses[50] = steam(50, "Fresh B")
	for id in range(1, 4):
		var url = "https://fixture.itch.io/game%d" % id
		itch_api.responses[url] = itch(url, "Fresh itch %d" % id, id)
	var history: Array = []
	var record = func(key, started_at): history.append({"key": key, "at": started_at, "active": worker._active})
	steam_api.request_started.connect(record)
	itch_api.request_started.connect(record)
	var panel = load("res://instances/users/pnl_user_games.tscn").instantiate()
	panel.hide()
	root.add_child(panel)
	panel.user = a
	await create_timer(0.35).timeout
	check(history.is_empty(), "hidden panels do not initiate refreshes")
	panel.show()
	check(panel.get_steam_app_ids().size() == 4 and panel.get_itchio_app_urls().size() == 3 and a.steam_app_ids[10].name == "Cached 10", "cached entries are visible before HTTP starts")
	await wait_until(func(): return history.size() == 5, "first batch launches five jobs")
	check(worker._active == 5, "maximum five automatic refreshes in flight")
	for i in range(1, 5):
		check(history[i].at - history[i - 1].at >= 250, "request starts are staggered")
	check(panel.get_node("%tab_game_info").visible == false, "background refresh does not open details")
	# A newer manual change must win over the already running automatic reply.
	panel._save_game_change(a.steam_app_ids, 10, steam(10, "Manual newer"))
	panel.user = b
	check(panel.get_steam_app_ids() == [50], "switching users immediately displays the new selection")
	panel.user = a
	panel.user = b
	await create_timer(0.35).timeout
	check(history.size() == 5, "selection changes cannot bypass the batch limit")
	var batch_completed = Time.get_ticks_msec()
	steam_api.release.emit()
	itch_api.release.emit()
	check(read_saved(a).steam_app_ids[11].name == "Fresh 11", "finished requests persist to the original user after selection changes")
	check(a.steam_app_ids[10].name == "Manual newer", "older automatic result cannot overwrite manual edits")
	check(a.steam_app_ids[12].name == "Cached 12", "failed refresh preserves cached info")
	check(panel.get_steam_app_ids() == [50], "A's results do not add entries to B's panel")
	await wait_until(func(): return history.size() == 8, "second batch includes remaining games and newly selected user")
	check(history[5].at - batch_completed >= 1900, "next batch waits two seconds after completion")
	check(history.all(func(item): return item.active <= 5), "all selected users share the same concurrency limit")
	steam_api.release.emit()
	itch_api.release.emit()
	await wait_until(func(): return not worker._running, "queue drains after both batches")
	check(read_saved(b).steam_app_ids[50].name == "Fresh B" and panel.get_node("%vb_steam_app_list").get_child(0).steam_data.name == "Fresh B", "selected user's entry and disk receive background results")
	check(read_saved(a).itchio_app_urls["https://fixture.itch.io/game3"].title == "Fresh itch 3", "itch metadata persists after its batch")
	panel.user = a
	panel.hide()
	panel.show()
	panel.user = b
	await create_timer(0.35).timeout
	check(history.size() == 8 and not worker._running, "reselection and reopening do not retry successes or failures this launch")
	panel.queue_free()
	await process_frame
	panel = load("res://instances/users/pnl_user_games.tscn").instantiate()
	root.add_child(panel)
	panel.user = a
	await create_timer(0.35).timeout
	check(history.size() == 8, "recreating the UI retains session refresh history")
	# Freshly added games already have current API data and need no automatic fetch.
	panel._save_game_change(a.steam_app_ids, 60, steam(60, "Just added"))
	panel.user = b
	panel.user = a
	check(not worker._running, "successful manual add suppresses redundant automatic fetch")
	# An unknown session game may be queued later, including failure rollback.
	a.steam_app_ids[70] = steam(70, "Keep after save failure")
	steam_api.responses[70] = steam(70, "Must roll back")
	panel.user = a
	await wait_until(func(): return history.size() == 9, "new association gets its own launch attempt")
	manager.fail_saves = true
	steam_api.release.emit()
	await wait_until(func(): return not worker._running, "failed persistence completes the job")
	check(a.steam_app_ids[70].name == "Keep after save failure" and panel.get_node("%games_error").visible, "save failure rolls back and appears on the selected panel")
	manager.fail_saves = false
	a.steam_app_ids[80] = steam(80, "To be deleted")
	steam_api.responses[80] = steam(80, "Must not restore")
	panel.user = a
	await wait_until(func(): return history.size() == 10, "deletion case starts a request")
	a.steam_app_ids.erase(80)
	steam_api.release.emit()
	await wait_until(func(): return not worker._running, "removed association completes without restoration")
	check(not a.steam_app_ids.has(80), "refresh never restores a removed game")
	a.steam_app_ids[90] = steam(90, "Removed user")
	steam_api.responses[90] = steam(90, "Must not resurrect")
	panel.user = a
	await wait_until(func(): return history.size() == 11, "user deletion case starts a request")
	manager.known.erase(a.user_id)
	var saves = manager.saves
	steam_api.release.emit()
	await wait_until(func(): return not worker._running, "removed user completes without restoration")
	check(manager.saves == saves and not manager.known.has(a.user_id), "refresh never restores a removed user")
	# A new manager represents another application launch, with no persisted flags.
	var next_manager = load("res://test/fixtures/user_games_manager.gd").new()
	root.add_child(next_manager)
	next_manager.known[b.user_id] = b
	var next_worker = next_manager.game_refresh
	var next_api = fake_api(next_worker.get_node("SteamService"))
	next_api.response = steam(50, "Next launch")
	next_worker.queue_user(b)
	await wait_until(func(): return next_api.calls == 1 and not next_worker._running, "a new application session refreshes games again")
	check(b.steam_app_ids[50].name == "Next launch", "refresh flags are never persisted to disk")
	next_manager.queue_free()
	panel.queue_free()
	await process_frame
	services.user_mng = original_manager
	manager.queue_free()
	await process_frame
	print("AUTO USER GAMES: ", checks, " checks, ", failures, " failures")
	quit(failures)
