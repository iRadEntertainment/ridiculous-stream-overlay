extends SceneTree
## Run headless with APPDATA pointing at res://.godot/user-games-test-data.
## Uses real user serialization/files and UI handlers, with deterministic API replies.

var failures = 0
var checks = 0
var user_script
var steam_script
var itch_script
var manager

func _initialize() -> void:
	_run.call_deferred()

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("USER GAMES FAIL: " + message)

func steam(app_id: int, title: String):
	var data = steam_script.new()
	data.steam_app_id = app_id
	data.name = title
	return data

func itch(url: String, title: String, game_id := 1):
	var data = itch_script.new()
	data.id = game_id
	data.title = title
	data.links = {"self": url}
	return data

func fake_api(node):
	node.set_script(load("res://test/fixtures/user_games_api.gd"))
	return node

func read_saved(user):
	return manager.load_user_from_json(manager.folder.path_join(manager.user_filename_json_from_user(user)))

func _run() -> void:
	var test_root = ProjectSettings.globalize_path("res://.godot/user-games-test-data")
	if not OS.get_user_data_dir().replace("\\", "/").begins_with(test_root + "/"):
		push_error("Run with isolated APPDATA at " + test_root)
		quit(2)
		return
	# Resolve project classes after the RS autoload has initialized.
	user_script = load("res://classes/RSUser.gd")
	steam_script = load("res://lib/games_info/SteamAppData.gd")
	itch_script = load("res://lib/games_info/ItchIOAppData.gd")
	var settings_script = load("res://classes/RSSettings.gd")
	settings_script.data_dir = test_root.path_join("run-%d" % Time.get_ticks_usec())
	var services = root.get_node("RS")
	var original_manager = services.user_mng
	manager = load("res://test/fixtures/user_games_manager.gd").new()
	root.add_child(manager)
	services.user_mng = manager
	var a = manager.observe_user(101, "fixture_a")
	var b = manager.observe_user(102, "fixture_b")
	var old_steam = steam(10, "Old Steam")
	var itch_url = "https://fixture.itch.io/game"
	var old_itch = itch(itch_url, "Old itch")
	a.steam_app_ids[10] = old_steam
	a.itchio_app_urls[itch_url] = old_itch
	a.website = "preserve-me"
	check(manager.save_user(a) and manager.save_user(b), "create isolated user files")
	var snapshot = a.to_dict()
	check(snapshot.steam_app_ids.has("10"), "serialize Steam keys as strings")
	var restored = user_script.from_json(snapshot)
	check(restored.steam_app_ids[10].name == "Old Steam" and restored.itchio_app_urls[itch_url].title == "Old itch" and restored.website == "preserve-me", "in-memory snapshot restores both stores and subsequent fields")
	snapshot.steam_app_ids = {10: old_steam.to_json()}
	check(user_script.from_json(snapshot).steam_app_ids.has(10), "legacy integer snapshot keys are accepted")
	check(read_saved(a).steam_app_ids[10].steam_app_id == 10, "JSON round trip restores numeric game identity")
	snapshot.steam_app_ids = {"bad": {}, "0": old_steam.to_json(), "12": null, "10": old_steam.to_json()}
	snapshot.itchio_app_urls = {"bad": [], itch_url: old_itch.to_json()}
	restored = user_script.from_json(snapshot)
	check(restored.steam_app_ids.size() == 1 and restored.itchio_app_urls.size() == 1, "skip malformed game association records")
	var panel = load("res://instances/users/pnl_user_games.tscn").instantiate()
	panel.hide() # Exercise manual edits independently of the automatic queue.
	root.add_child(panel)
	var saves = manager.saves
	panel.user = a
	panel.user = a
	check(manager.saves == saves, "displaying games never writes user data")
	check(panel.get_steam_app_ids().size() == 1 and panel.get_itchio_app_urls().size() == 1, "repopulation does not lose entries queued for deletion")
	var steam_api = fake_api(panel.pnl_steam_app_info.get_node("%SteamService"))
	var itch_api = fake_api(panel.pnl_itchio_app_info.get_node("%ItchIOService"))
	steam_api.response = steam(20, "Added Steam")
	panel.get_node("%ln_add_steam_app_id").text = "https://store.steampowered.com/app/20/title/"
	await panel._on_btn_steam_add_game_pressed()
	check(read_saved(a).steam_app_ids[20].name == "Added Steam", "Steam add button parses URL and autosaves")
	itch_api.response = itch("https://fixture.itch.io/new-game/", "Added itch", 2)
	panel.get_node("%ln_add_itch_io_link").text = " https://fixture.itch.io/new-game/ "
	await panel._on_btn_itchio_add_game_pressed()
	check(read_saved(a).itchio_app_urls.has("https://fixture.itch.io/new-game"), "itch add button autosaves canonical key")
	await panel.add_itchio_entry("https://fixture.itch.io/new-game", true)
	check(a.itchio_app_urls.size() == 2 and panel.get_itchio_app_urls().size() == 2, "canonical itch URL does not duplicate entry")
	var steam_entry = panel.get_node("%vb_steam_app_list").get_child(0)
	var itch_entry = panel.get_node("%vb_itch_app_list").get_child(0)
	var steam_refresh_api = fake_api(steam_entry.get_node("SteamService"))
	var itch_refresh_api = fake_api(itch_entry.get_node("ItchIOService"))
	steam_refresh_api.response = steam(10, "Refreshed Steam")
	itch_refresh_api.response = itch(itch_url, "Refreshed itch")
	await steam_entry._on_btn_reload_pressed()
	await itch_entry._on_btn_reload_pressed()
	check(read_saved(a).steam_app_ids[10].name == "Refreshed Steam" and steam_entry.steam_data == a.steam_app_ids[10], "Steam refresh updates canonical data, entry and disk")
	check(read_saved(a).itchio_app_urls[itch_url].title == "Refreshed itch" and itch_entry.itchio_data == a.itchio_app_urls[itch_url], "itch refresh updates canonical data, entry and disk")
	saves = manager.saves
	steam_refresh_api.response = null
	itch_refresh_api.response = null
	await steam_entry._on_btn_reload_pressed()
	await itch_entry._on_btn_reload_pressed()
	check(manager.saves == saves and steam_entry.steam_data.name == "Refreshed Steam" and itch_entry.itchio_data.title == "Refreshed itch", "API failure preserves saved and displayed data")
	check(not steam_entry.get_node("hb/btn_reload").disabled and not itch_entry.get_node("hb/btn_reload").disabled, "refresh buttons recover after failures")
	steam_refresh_api.response = steam(99, "Wrong ID")
	itch_refresh_api.response = itch(itch_url, "Wrong ID", 99)
	await steam_entry._on_btn_reload_pressed()
	await itch_entry._on_btn_reload_pressed()
	check(manager.saves == saves, "mismatched game IDs are not persisted")
	manager.fail_saves = true
	steam_refresh_api.response = steam(10, "Unsaved Steam")
	itch_refresh_api.response = itch(itch_url, "Unsaved itch")
	await steam_entry._on_btn_reload_pressed()
	await itch_entry._on_btn_reload_pressed()
	check(a.steam_app_ids[10].name == "Refreshed Steam" and a.itchio_app_urls[itch_url].title == "Refreshed itch", "failed save rolls back refreshed data in memory")
	check(steam_entry.steam_data.name == "Refreshed Steam" and itch_entry.itchio_data.title == "Refreshed itch" and panel.get_node("%games_error").visible, "failed save keeps entries and displays an error")
	steam_entry._on_btn_delete_pressed()
	itch_entry._on_btn_delete_pressed()
	check(a.steam_app_ids.has(10) and a.itchio_app_urls.has(itch_url) and steam_entry.is_inside_tree() and itch_entry.is_inside_tree(), "failed deletion save retains associations and widgets")
	check(not await panel.add_steam_entry(30, true, steam(30, "Unsaved addition")) and not a.steam_app_ids.has(30), "failed addition save rolls back association")
	manager.fail_saves = false
	steam_entry._on_btn_delete_pressed()
	itch_entry._on_btn_delete_pressed()
	check(not read_saved(a).steam_app_ids.has(10) and not read_saved(a).itchio_app_urls.has(itch_url), "both delete buttons persist removals")
	check(not steam_entry.is_inside_tree() and not itch_entry.is_inside_tree(), "delete removes widgets only after saving")
	steam_api.delayed = true
	itch_api.delayed = true
	steam_api.response = steam(30, "Stale addition")
	itch_api.response = itch("https://fixture.itch.io/stale", "Stale addition", 3)
	panel.add_steam_entry(30, true)
	panel.add_itchio_entry("https://fixture.itch.io/stale", true)
	saves = manager.saves
	panel.user = b
	steam_api.release.emit()
	itch_api.release.emit()
	check(manager.saves == saves and b.steam_app_ids.is_empty() and b.itchio_app_urls.is_empty() and not a.steam_app_ids.has(30), "selection change discards stale additions for both APIs")
	panel.user = a
	steam_api.response = steam(31, "Concurrent A")
	panel.add_steam_entry(31, true)
	steam_api.response = steam(32, "Concurrent B")
	panel.add_steam_entry(32, true)
	steam_api.release.emit()
	check(read_saved(a).steam_app_ids[31].name == "Concurrent A" and read_saved(a).steam_app_ids[32].name == "Concurrent B", "concurrent requests keep their own results")
	steam_entry = panel.get_node("%vb_steam_app_list").get_child(0)
	steam_refresh_api = fake_api(steam_entry.get_node("SteamService"))
	steam_refresh_api.delayed = true
	steam_refresh_api.response = steam(steam_entry.steam_app_id, "Removed user")
	steam_entry._on_btn_reload_pressed()
	saves = manager.saves
	manager.known.erase(a.user_id)
	steam_refresh_api.release.emit()
	check(manager.saves == saves and not manager.known.has(a.user_id), "pending refresh cannot re-add a deleted user")
	panel.queue_free()
	await process_frame
	services.user_mng = original_manager
	manager.queue_free()
	await process_frame
	print("USER GAMES: ", checks, " checks, ", failures, " failures")
	quit(failures)
