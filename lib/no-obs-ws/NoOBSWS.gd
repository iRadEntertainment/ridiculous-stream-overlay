extends Node
class_name NoOBSWS

const NoOBSAuthenticator := preload("res://lib/no-obs-ws/Authenticator.gd")
const NoOBSEnums := preload("res://lib/no-obs-ws/Utility/Enums.gd")

static var _log: TwitchLogger = TwitchLogger.new(&"NoOBSWS")

var _ws: WebSocketPeer
# {request_id: NoOBSRequestResponse}
var _requests: Dictionary = {}
var _batch_requests: Dictionary = {}

signal connection_ready()
signal connection_failed()
signal connection_closed_clean(code: int, reason: String)

signal error(message: String)
signal event_received(event: NoOBSMessage)
signal _auth_required()

signal scenes_updated

var is_state_open : bool:
	get():
		return _ws.get_ready_state() == WebSocketPeer.STATE_OPEN

var is_stream_on := true:
	set(val):
		is_stream_on = val
		scenes_updated.emit()
var is_mic_muted := false:
	set(val):
		is_mic_muted = val
		scenes_updated.emit()
		var mute_icon_id = await get_scene_item_id("Overlay Stream", "mute_icon")
		set_item_enabled("Overlay Stream", mute_icon_id, val)
var is_brave_muted := false:
	set(val):
		is_brave_muted = val
		scenes_updated.emit()
var is_pixelate_on := false:
	set(val):
		is_pixelate_on = val
		scenes_updated.emit()


func start():
	_log.i("Module Started. Not connected to WS.")
	event_received.connect(_on_event_received)
	
	var has_all := true
	if !RS.settings.obs_websocket_url: has_all = false
	elif !RS.settings.obs_websocket_port: has_all = false
	
	if !has_all:
		_log.w("Missing settings for OBS Autoconnect")
		return
	if RS.settings.obs_autoconnect:
		start_connection()


func start_connection() -> void:
	_log.i("Connecting to %s:%s" % [RS.settings.obs_websocket_url, RS.settings.obs_websocket_port])
	connect_to_obsws(RS.settings.obs_websocket_port, RS.settings.obs_websocket_password)
	if !is_state_open:
		await connection_ready
	
	is_mic_muted = await get_input_mute("Mic/Aux")
	is_brave_muted = await get_input_mute("Brave")
	is_stream_on = await get_stream_status()
	is_pixelate_on = await get_item_filter_enabled("main_desk", "Blur")
	

func _on_event_received(event: NoOBSMessage) -> void:
	var data := event.get_data()
	if !data.has("event_type"): return
	if data.event_type == "StreamStateChanged":
		is_stream_on = data.event_data.output_active
	if data.event_type == "InputMuteStateChanged":
		match data.event_data.input_name:
			"Mic/Aux": is_mic_muted = data.event_data.input_muted
			"Brave": is_brave_muted = data.event_data.input_muted

func get_stream_status() -> bool:
	var request_type = "GetStreamStatus"
	var request := make_generic_request(request_type)
	await request.response_received
	var response = request.message.get_data()
	return response.response_data.output_active as bool

func get_scene_item_id(scene_name : String, source_name: String) -> int:
	var request_type = "GetSceneItemId"
	var request_data = {"scene_name": scene_name, "source_name": source_name}
	var request := make_generic_request(request_type, request_data)
	await request.response_received
	var response = request.message.get_data()
	return response.response_data.scene_item_id as int


func get_item_enabled(scene_name: String, item_id: int) -> bool:
	var request_type = "GetSceneItemEnabled"
	var request_data = {"scene_name": scene_name, "scene_item_id": item_id}
	var request = make_generic_request(request_type, request_data)
	await request.response_received
	var response = request.message.get_data()
	return response.response_data.scene_item_enabled


func set_item_enabled(scene_name: String, item_id: int, val: bool) -> void:
	var request_type = "SetSceneItemEnabled"
	var request_data = {"scene_name": scene_name, "scene_item_id": item_id, "scene_item_enabled": val}
	make_generic_request(request_type, request_data)


func get_input_mute(input_name: String) -> bool:
	var request_type = "GetInputMute"
	var request_data = {"input_name": input_name}
	var request = make_generic_request(request_type, request_data)
	await request.response_received
	var response = request.message.get_data()
	return response.response_data.input_muted


func set_input_mute(input_name: String, val: bool) -> void:
	var request_type = "SetInputMute"
	var request_data = {"input_name": input_name, "input_muted": val}
	make_generic_request(request_type, request_data)


func get_item_filter_enabled(source_name: String, filter_name: String) -> bool:
	var request_type = "GetSourceFilter"
	var request_data = {
			"source_name": source_name,
			"filter_name": filter_name
		}
	var request = make_generic_request(request_type, request_data)
	await request.response_received
	var response = request.message.get_data()
	return response.response_data.filter_enabled


func set_item_filter_enabled(source_name: String, filter_name: String, filter_enabled: bool) -> void:
	var request_type = "SetSourceFilterEnabled"
	var request_data = {
			"source_name": source_name,
			"filter_name": filter_name,
			"filter_enabled": filter_enabled
		}
	make_generic_request(request_type, request_data)


func get_item_filter_setting(source_name: String, filter_name: String) -> Dictionary:
	var request_type = "GetSourceFilter"
	var request_data = {
			"source_name": source_name,
			"filter_name": filter_name
		}
	var request = make_generic_request(request_type, request_data)
	await request.response_received
	var response = request.message.get_data()
	return response.response_data.filter_settings


func set_item_filter_setting(source_name: String, filter_name: String, filter_settings: Dictionary) -> void:
	var request_type = "SetSourceFilterSettings"
	var request_data = {
			"sourceName": source_name,
			"filterName": filter_name,
			"filterSettings": filter_settings,
			"overlay": true
		}
	var res: NoOBSRequestResponse = make_generic_request(request_type, request_data, false)
	await res.response_received


func toggle_mic_mute() -> void:
	is_mic_muted = !is_mic_muted
	set_input_mute("Mic/Aux", is_mic_muted)
func toggle_brave_mute() -> void:
	is_brave_muted = !is_brave_muted
	set_input_mute("Brave", is_brave_muted)


func stop_stream() -> void:
	var request_type = "StopStream"
	var request_data = {}
	var request = make_generic_request(request_type, request_data)
	await request.response_received


func restart_media(media_name) -> void:
	var request_type = "TriggerMediaInputAction"
	var request_data = {"input_name": media_name, "media_action": "OBS_WEBSOCKET_MEDIA_INPUT_ACTION_RESTART"}
	var request = make_generic_request(request_type, request_data)
	await request.response_received


# ============================ TheYagich OG code ============================
func connect_to_obsws(port: int, password: String = "") -> void:
	if password.is_empty():
		_log.e("Websocket password missing.")
		return
	_ws = WebSocketPeer.new()
	var err := _ws.connect_to_url("%s:%s" % [RS.settings.obs_websocket_url, port])
	if err == OK:
		if not _auth_required.is_connected(_authenticate):
			_auth_required.connect(_authenticate.bind(password))
	else:
		_log.e("Couldn't connect. Error: %s" % err)


func make_generic_request(
			request_type: String,
			request_data: Dictionary = {},
			do_convert: bool = true
		) -> NoOBSRequestResponse:
	var response := NoOBSRequestResponse.new()
	var message := NoOBSMessage.new()
	message.do_convert = do_convert
	
	var crypto := Crypto.new()
	var request_id := crypto.generate_random_bytes(16).hex_encode()
	var data := {
		"request_type": request_type,
		"request_id": request_id,
		"request_data": request_data,
	}
	if not do_convert:
		data = {
			"requestType": request_type,
			"requestId": request_id,
			"requestData": request_data,
		}
	message._d.merge(data, true)

	message.op_code = NoOBSEnums.WebSocketOpCode.REQUEST

	response.id = request_id
	response.type = request_type

	_requests[request_id] = response

	_send_message(message)

	return response


func make_batch_request(halt_on_failure: bool = false, execution_type: NoOBSEnums.RequestBatchExecutionType = NoOBSEnums.RequestBatchExecutionType.SERIAL_REALTIME) -> NoOBSBatchRequest:
	var batch_request := NoOBSBatchRequest.new()

	var crypto := Crypto.new()
	var request_id := crypto.generate_random_bytes(16).hex_encode()

	batch_request._id = request_id
	batch_request._send_callback = _send_message

	batch_request.halt_on_failure = halt_on_failure
	batch_request.execution_type = execution_type

	_batch_requests[request_id] = batch_request

	return batch_request


var tick = 0
var tick_freq = 0.2
func _process(d: float) -> void:
	tick += d
	if tick < tick_freq: return
	tick = 0
	if is_instance_valid(_ws):
		_poll_socket()


func _poll_socket() -> void:
	_ws.poll()

	var state = _ws.get_ready_state()
	match state:
		WebSocketPeer.STATE_OPEN:
			while _ws.get_available_packet_count():
				_handle_packet(_ws.get_packet())
		WebSocketPeer.STATE_CLOSING:
			pass
		WebSocketPeer.STATE_CLOSED:
			if _ws.get_close_code() == -1:
				connection_failed.emit()
			else:
				connection_closed_clean.emit(_ws.get_close_code(), _ws.get_close_reason())
			_log.i("Connection closing. Code {}")
			_ws = null


func _handle_packet(packet: PackedByteArray) -> void:
	var message = NoOBSMessage.from_json(packet.get_string_from_utf8())
	_handle_message(message)


func _handle_message(message: NoOBSMessage) -> void:
	match message.op_code:
		NoOBSEnums.WebSocketOpCode.HELLO:
			if message.get("authentication") != null:
				_auth_required.emit(message)
				_log.w("Auth required.")
			else:
				var m = NoOBSMessage.new()
				m.op_code = NoOBSEnums.WebSocketOpCode.IDENTIFY
				_send_message(m)

		NoOBSEnums.WebSocketOpCode.IDENTIFIED:
			connection_ready.emit()
			_log.i("Connected.")

		NoOBSEnums.WebSocketOpCode.EVENT:
			event_received.emit(message)

		NoOBSEnums.WebSocketOpCode.REQUEST_RESPONSE:
			var id = message.get_data().get("request_id")
			if id == null:
				_log.e("Received request response, but there was no request id field.")
				error.emit("Received request response, but there was no request id field.")
				return

			var response = _requests.get(id) as NoOBSRequestResponse
			if response == null:
				_log.e("Received request response, but there was no request made with that id.")
				error.emit("Received request response, but there was no request made with that id.")
				return

			response.message = message

			response.response_received.emit()
			_requests.erase(id)

		NoOBSEnums.WebSocketOpCode.REQUEST_BATCH_RESPONSE:
			var id = message.get_data().get("request_id")
			if id == null:
				error.emit("Received batch request response, but there was no request id field.")
				return

			var response = _batch_requests.get(id) as NoOBSBatchRequest
			if response == null:
				error.emit("Received batch request response, but there was no request made with that id.")
				return

			response.response = message

			response.response_received.emit()
			_batch_requests.erase(id)


func _send_message(message: NoOBSMessage) -> void:
	if not _ws:
		_log.e("WebSocket not initialized")
		_log.w("Cannot send message with code: %s" % message.op_code)
		return
	if _ws.get_ready_state() != WebSocketPeer.STATE_OPEN:
		_log.e("WebSocket not open")
		_log.w("Cannot send message with code: %s" % message.op_code)
		return
	_ws.send_text(message.to_obsws_json())


func _authenticate(message: NoOBSMessage, password: String) -> void:
	var authenticator = NoOBSAuthenticator.new(
		password,
		message.authentication.challenge,
		message.authentication.salt,
	)
	var auth_string = authenticator.get_auth_string()
	var m = NoOBSMessage.new()
	m.op_code = NoOBSEnums.WebSocketOpCode.IDENTIFY
	m._d["authentication"] = auth_string
	_log.i("Authentication...")
	_log.i(m._to_string())
	_send_message(m)


class NoOBSMessage:
	var op_code: int
	var _d: Dictionary = {"rpc_version": 1}
	var do_convert: bool = true
	
	func _get(property: StringName):
		if property in _d:
			return _d[property]
		else:
			return null
	
	
	func _get_property_list() -> Array:
		var prop_list = []
		_d.keys().map(
			func(x):
				var d = {
					"name": x,
					"type": typeof(_d[x])
				}
				prop_list.append(d)
		)
		return prop_list
	
	
	func to_obsws_json() -> String:
		var data = {
			"op": op_code,
			"d": {}
		}
		if do_convert:
			data.d = snake_to_camel_recursive(_d)
		else:
			data.d = _d
		return JSON.stringify(data)
	
	
	func get_data() -> Dictionary:
		return _d
	
	
	func _to_string() -> String:
		return var_to_str(_d)


	static func from_json(json: String) -> NoOBSMessage:
		var ev = NoOBSMessage.new()
		var dictified = JSON.parse_string(json)

		if dictified == null:
			return null

		dictified = dictified as Dictionary
		ev.op_code = dictified.get("op", -1)
		var data = dictified.get("d", null)
		if data == null:
			return null

		data = data as Dictionary
		ev._d = camel_to_snake_recursive(data)

		return ev


	static func camel_to_snake_recursive(d: Dictionary) -> Dictionary:
		var snaked = {}
		for prop in d:
			prop = prop as String
			if d[prop] is Dictionary:
				snaked[prop.to_snake_case()] = camel_to_snake_recursive(d[prop])
			else:
				snaked[prop.to_snake_case()] = d[prop]
		return snaked


	static func snake_to_camel_recursive(d: Dictionary) -> Dictionary:
		var cameled = {}
		for prop in d:
			prop = prop as String
			if d[prop] is Dictionary:
				cameled[prop.to_camel_case()] = snake_to_camel_recursive(d[prop])
			else:
				cameled[prop.to_camel_case()] = d[prop]
		return cameled


class NoOBSRequestResponse:
	signal response_received()

	var id: String
	var type: String
	var message: NoOBSMessage


class NoOBSBatchRequest:
	@warning_ignore("unused_signal")
	signal response_received()

	var _id: String
	var _send_callback: Callable

	var halt_on_failure: bool = false
	var execution_type: NoOBSEnums.RequestBatchExecutionType = NoOBSEnums.RequestBatchExecutionType.SERIAL_REALTIME

	var requests: Array[NoOBSMessage]
	# {String: int}
	var request_ids: Dictionary

	var response: NoOBSMessage = null

	func send() -> void:
		var message = NoOBSMessage.new()
		message.op_code = NoOBSEnums.WebSocketOpCode.REQUEST_BATCH
		message._d["halt_on_failure"] = halt_on_failure
		message._d["execution_type"] = execution_type
		message._d["request_id"] = _id
		message._d["requests"] = []
		for r in requests:
			message._d.requests.append(NoOBSMessage.snake_to_camel_recursive(r.get_data()))

		_send_callback.call(message)


	func add_request(request_type: String, request_id: String = "", request_data: Dictionary = {}) -> int:
		var message = NoOBSMessage.new()

		if request_id == "":
			var crypto := Crypto.new()
			request_id = crypto.generate_random_bytes(16).hex_encode()

		var data := {
			"request_type": request_type,
			"request_id": request_id,
			"request_data": request_data,
		}

		message._d.merge(data, true)
		message.op_code = NoOBSEnums.WebSocketOpCode.REQUEST

		requests.append(message)
		request_ids[request_id] = requests.size() - 1

		return request_ids[request_id]
