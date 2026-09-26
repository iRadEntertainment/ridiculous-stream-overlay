extends Node

signal release
signal request_started(key: Variant, started_at: int)
var response: Resource
var responses: Dictionary = {}
var delayed := false
var calls := 0

func get_steam_app_data(app_id: int) -> Resource:
	return await _fetch(app_id)

func get_itch_app_data(url: String) -> Resource:
	return await _fetch(url)

func _fetch(key: Variant) -> Resource:
	calls += 1
	var result: Resource = responses.get(key, response)
	request_started.emit(key, Time.get_ticks_msec())
	if delayed:
		await release
	return result
