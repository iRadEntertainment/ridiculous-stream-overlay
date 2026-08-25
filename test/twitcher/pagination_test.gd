extends SceneTree
## Offline reproduction for the paginated-response hang.
##
## Drives the real generated TwitchGetStreams.Response with a fake transport,
## so it needs no Twitch account and no live streamers.
##
##   godot --headless --path . --script res://test/twitcher/pagination_test.gd
##
## On unpatched code the plain `for` loop never terminates (the guard stops it).
## On patched code the loop walks one page and all() returns every item.

const PAGES := [["alice", "bob", "carol"], ["dave", "erin"], ["frank"]]


func _make_stream(login: String) -> TwitchStream:
	var s := TwitchStream.new()
	s.user_id = str(hash(login) % 100000)
	s.user_login = login
	s.user_name = login
	return s


func _make_page(idx: int) -> TwitchGetStreams.Response:
	var r := TwitchGetStreams.Response.new()
	var items: Array[TwitchStream] = []
	for login: String in PAGES[idx]:
		items.append(_make_stream(login))
	r.data = items

	var p := TwitchGetStreams.ResponsePagination.new()
	# Twitch sends an empty pagination object once there is nothing left.
	p.cursor = "cursor%d" % idx if idx < PAGES.size() - 1 else ""
	r.pagination = p

	if idx < PAGES.size() - 1:
		# Stand-in for the HTTP request: it must actually suspend, because that
		# is precisely what breaks the iterator.
		r._next_page = func() -> TwitchGetStreams.Response:
			await process_frame
			return _make_page(idx + 1)
	return r


func _initialize() -> void:
	var total := 0
	for page: Array in PAGES:
		total += page.size()
	print("--- paginated response test ---")
	print("pages: %s   total items: %d" % [str(PAGES.map(func(p): return p.size())), total])

	# 1. plain iteration, the way the app used to consume responses
	var seen: Array[String] = []
	var guard := 0
	var hung := false
	for stream in _make_page(0):
		guard += 1
		if guard > total * 5 + 20:
			hung = true
			break
		if stream is TwitchStream:
			seen.append(stream.user_login)
		else:
			seen.append("<%s>" % type_string(typeof(stream)))
	if hung:
		print("  for-loop : HANGS (stopped by guard after %d iterations)" % guard)
		print("             yielded: %s ..." % str(seen.slice(0, 6)))
	else:
		print("  for-loop : terminated, %d/%d items %s" % [seen.size(), total, str(seen)])

	# 2. the fix
	var page := _make_page(0)
	if page.has_method("all"):
		var logins: Array[String] = []
		for stream: TwitchStream in await page.all():
			logins.append(stream.user_login)
		var ok := logins.size() == total
		print("  all()    : %s  %d/%d items %s" % ["PASS" if ok else "FAIL", logins.size(), total, str(logins)])
	else:
		print("  all()    : not present on this branch (unpatched)")

	quit()
