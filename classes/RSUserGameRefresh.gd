extends Node
class_name RSUserGameRefresh
## Session-only refresh state, owned by RSUserMng rather than a user panel.

static var _log: TwitchLogger = TwitchLogger.new(&"RSUserGameRefresh")

const BATCH_SIZE := 5
const START_DELAY := 0.25
const REQUEST_STAGGER := 0.3
const BATCH_PAUSE := 2.0

var _queue: Array[Dictionary] = []
var _queued: Dictionary[String, bool] = {}
var _attempted: Dictionary[String, bool] = {}
var _running := false
var _active := 0

signal job_finished
signal game_refresh_finished(user: RSUser, kind: String, key: Variant, success: bool, message: String)

func _ready() -> void:
	var steam := SteamService.new()
	steam.name = "SteamService"
	add_child(steam)
	var itch := ItchIOService.new()
	itch.name = "ItchIOService"
	add_child(itch)

func _job_id(user: RSUser, kind: String, key: Variant) -> String:
	return "%d:%s:%s" % [user.user_id, kind, str(key)]

func mark_refreshed(user: RSUser, kind: String, key: Variant) -> void:
	# A successful add/manual update already fetched this game's info this launch.
	_attempted[_job_id(user, kind, key)] = true
	_log.d("Marked current after manual save: user=%s (%d), store=%s, game=%s" % [user.username, user.user_id, kind, key])

func queue_user(user: RSUser) -> void:
	if user == null:
		_log.d("Refresh trigger ignored: no user selected.")
		return
	if get_parent().get_known_user_from_user_id(user.user_id) != user:
		_log.w("Refresh trigger ignored for %s (%d): user is no longer the current known-user record." % [user.username, user.user_id])
		return
	var previous_size := _queue.size()
	for key: int in user.steam_app_ids:
		_enqueue(user, "steam", key, user.steam_app_ids[key])
	for key: String in user.itchio_app_urls:
		_enqueue(user, "itch", key, user.itchio_app_urls[key])
	var added := _queue.size() - previous_size
	var total := user.steam_app_ids.size() + user.itchio_app_urls.size()
	_log.i("Refresh triggered for %s (%d): %d games, %d newly queued, %d already queued or attempted this launch. Queue=%d, active=%d." % [user.username, user.user_id, total, added, total - added, _queue.size(), _active])
	if not _running and not _queue.is_empty():
		_running = true
		_run_queue.call_deferred()

func _enqueue(user: RSUser, kind: String, key: Variant, original: Resource) -> void:
	var id := _job_id(user, kind, key)
	if _attempted.has(id) or _queued.has(id):
		return
	_queued[id] = true
	_queue.append({"id": id, "user": user, "kind": kind, "key": key, "original": original})

func _games(job: Dictionary) -> Dictionary:
	return job.user.steam_app_ids if job.kind == "steam" else job.user.itchio_app_urls

func _is_current(job: Dictionary) -> bool:
	return get_parent().get_known_user_from_user_id(job.user.user_id) == job.user \
		and _games(job).has(job.key) and _games(job)[job.key] == job.original

func _describe_job(job: Dictionary) -> String:
	return "user=%s (%d), store=%s, game=%s" % [job.user.username, job.user.user_id, job.kind, job.key]

func _run_queue() -> void:
	var started_at := Time.get_ticks_msec()
	var batch := 0
	var started := 0
	_log.i("Queue starting in %.2fs: batches of %d, %.2fs between request starts, %.1fs between batches." % [START_DELAY, BATCH_SIZE, REQUEST_STAGGER, BATCH_PAUSE])
	# Give the panel a frame to show cached data before starting network work.
	await get_tree().create_timer(START_DELAY, true, false, true).timeout
	while not _queue.is_empty():
		batch += 1
		_log.i("Batch %d starting: %d jobs waiting." % [batch, _queue.size()])
		var launched := 0
		while launched < BATCH_SIZE and not _queue.is_empty():
			var job: Dictionary = _queue.pop_front()
			_queued.erase(job.id)
			if _attempted.has(job.id):
				_log.i("Skipping queued refresh (%s): already attempted or manually updated this launch." % _describe_job(job))
				continue
			if not _is_current(job):
				_log.i("Skipping queued refresh (%s): user or game was removed, replaced, or edited." % _describe_job(job))
				continue
			_attempted[job.id] = true
			_active += 1
			launched += 1
			started += 1
			_refresh_job(job)
			if launched < BATCH_SIZE and not _queue.is_empty():
				await get_tree().create_timer(REQUEST_STAGGER, true, false, true).timeout
		while _active > 0:
			await job_finished
		_log.i("Batch %d finished: %d requests completed, %d jobs waiting." % [batch, launched, _queue.size()])
		if not _queue.is_empty():
			_log.i("Waiting %.1fs before the next batch." % BATCH_PAUSE)
			await get_tree().create_timer(BATCH_PAUSE, true, false, true).timeout
	_running = false
	_log.i("Queue drained: %d refreshes started in %.2fs." % [started, (Time.get_ticks_msec() - started_at) / 1000.0])

func _refresh_job(job: Dictionary) -> void:
	var started_at := Time.get_ticks_msec()
	var context := _describe_job(job)
	_log.i("Fetching game info (%s). Active=%d." % [context, _active])
	var data: Resource
	if job.kind == "steam":
		data = await $SteamService.get_steam_app_data(job.key)
		if data != null and data.steam_app_id != job.key:
			_log.w("Rejected Steam response (%s): returned app ID %d." % [context, data.steam_app_id])
			data = null
	else:
		data = await $ItchIOService.get_itch_app_data(job.key)
		if data != null and (data.url.is_empty() or (job.original != null and job.original.id > 0 and data.id != job.original.id)):
			_log.w("Rejected itch.io response (%s): missing URL or mismatched game ID (returned %d)." % [context, data.id])
			data = null
	# Selection may change, but the original user can still receive the result.
	# Deletion, replacement, or a newer manual edit invalidates it instead.
	if _is_current(job):
		var success := false
		var message := "Could not refresh game info. Previous data was kept; use Update to retry."
		if data != null:
			var games := _games(job)
			games[job.key] = data
			success = get_parent().save_user(job.user)
			if not success:
				games[job.key] = job.original
				message = "Could not save refreshed game info. Previous data was kept; use Update to retry."
				_log.e("Save failed (%s): restored previous game info. Use Update to retry." % context)
			else:
				_log.i("Refreshed and saved (%s) in %.2fs." % [context, (Time.get_ticks_msec() - started_at) / 1000.0])
		else:
			_log.w("Refresh failed (%s) after %.2fs: no usable API result; previous data kept. No automatic retry this launch; use Update." % [context, (Time.get_ticks_msec() - started_at) / 1000.0])
		game_refresh_finished.emit(job.user, job.kind, job.key, success, "" if success else message)
	else:
		_log.i("Discarded completed refresh (%s) after %.2fs: user or game was removed, replaced, or edited while fetching." % [context, (Time.get_ticks_msec() - started_at) / 1000.0])
	_active -= 1
	job_finished.emit()
