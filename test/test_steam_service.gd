extends "res://test/test_user_games.gd"
## Same isolated APPDATA as test_user_games.gd. Captured live responses in
## .godot are optional; synthetic cases always exercise the response contract.

func record(app_id: int, title: String) -> Dictionary:
	return {"success": true, "data": {"steam_appid": app_id, "name": title}}

func _run() -> void:
	var test_root = ProjectSettings.globalize_path("res://.godot/user-games-test-data")
	if not OS.get_user_data_dir().replace("\\", "/").begins_with(test_root + "/"):
		push_error("Run with isolated APPDATA at " + test_root)
		quit(2)
		return
	var service = load("res://lib/games_info/SteamService.gd").new()
	root.add_child(service)
	var response = {"4483400": record(4483400, "Requested game")}
	var data = service._parse_app_details(response, 4483400)
	check(data != null and data.steam_app_id == 4483400 and data.name == "Requested game", "normal keyed response")
	check(not response["4483400"].data.has("steam_app_id"), "parsing does not modify the API response")
	response = {"5310040": record(4483400, "MR MAGEBOY")}
	data = service._parse_app_details(response, 4483400)
	check(data != null and data.steam_app_id == 4483400 and data.name == "MR MAGEBOY", "mismatched envelope key accepts verified payload ID")
	check(service._parse_app_details({"4483400": record(570, "Wrong game")}, 4483400) == null, "correct envelope key cannot override wrong payload ID")
	check(service._parse_app_details({"5310040": record(570, "Wrong game")}, 4483400) == null, "fallback never accepts an unrelated first record")
	response = {"4483400": record(570, "Wrong game"), "5310040": record(4483400, "Correct game")}
	check(service._parse_app_details(response, 4483400).name == "Correct game", "fallback locates requested ID among other records")
	check(service._parse_app_details({"4483400": {"success": false, "data": {"steam_appid": 4483400}}}, 4483400) == null, "unsuccessful record is rejected")
	check(service._parse_app_details({"4483400": {"success": true}}, 4483400) == null, "missing metadata is rejected")
	check(service._parse_app_details([], 4483400) == null, "invalid root shape is rejected")
	response = {"a": record(4483400, "One"), "b": record(4483400, "Two")}
	check(service._parse_app_details(response, 4483400) == null, "ambiguous fallback is rejected")
	var captured_game = null
	for capture in [
		["res://.godot/steam-4483400-default.json", 4483400, "MR MAGEBOY"],
		["res://.godot/steam-check-english.json", 4483400, "MR MAGEBOY"],
		["res://.godot/steam-check-control.json", 570, "Dota 2"],
	]:
		if not FileAccess.file_exists(capture[0]):
			continue
		var body = FileAccess.get_file_as_string(capture[0]).trim_prefix("\ufeff")
		data = service._parse_app_details(JSON.parse_string(body), capture[1])
		check(data != null and data.steam_app_id == capture[1] and data.name == capture[2], "decode captured live response: " + capture[0])
		if capture[1] == 4483400:
			captured_game = data
	if captured_game == null:
		captured_game = service._parse_app_details({"5310040": record(4483400, "MR MAGEBOY")}, 4483400)
	# Exercise the actual Add button with the decoded response; omit image HTTP.
	captured_game.header_image = ""
	var settings_script = load("res://classes/RSSettings.gd")
	settings_script.data_dir = test_root.path_join("steam-parser-%d" % Time.get_ticks_usec())
	var services = root.get_node("RS")
	var original_manager = services.user_mng
	manager = load("res://test/fixtures/user_games_manager.gd").new()
	root.add_child(manager)
	services.user_mng = manager
	var user = manager.observe_user(301, "steam_parser_fixture")
	manager.save_user(user)
	var panel = load("res://instances/users/pnl_user_games.tscn").instantiate()
	panel.hide()
	root.add_child(panel)
	panel.user = user
	var api = fake_api(panel.pnl_steam_app_info.get_node("%SteamService"))
	api.response = captured_game
	panel.get_node("%ln_add_steam_app_id").text = "4483400"
	await panel._on_btn_steam_add_game_pressed()
	var saved = read_saved(user)
	check(saved.steam_app_ids.has(4483400) and saved.steam_app_ids[4483400].name == "MR MAGEBOY", "UI Add automatically persists the requested app ID and metadata")
	check(not saved.steam_app_ids.has(5310040) and panel.get_steam_app_ids() == [4483400], "envelope ID never becomes a saved or displayed association")
	panel.queue_free()
	service.queue_free()
	await process_frame
	services.user_mng = original_manager
	manager.queue_free()
	await process_frame
	print("STEAM SERVICE: ", checks, " checks, ", failures, " failures")
	quit(failures)
