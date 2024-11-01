@tool
extends Object
class_name RSSettings

# UI settings
static var app_scale: float = 1


static var _auto_connect : TwitchSetting.Property
static var auto_connect : bool :
	get: return _auto_connect.get_val()
	set(value): _auto_connect.set_val(value)

static var _max_messages_in_chat : TwitchSetting.Property
static var max_messages_in_chat : int :
	get: return _max_messages_in_chat.get_val()
	set(value): _max_messages_in_chat.set_val(value)

const SCOPES_DEFAULT_DIC := {
			"twitch/auth/scopes/chat": int(0),
			"twitch/auth/scopes/channel": int(0),
			"twitch/auth/scopes/moderator": int(0),
			"twitch/auth/scopes/user": int(0),
		}
static var scopes : Dictionary :
	get: return get_scopes()
	set(value): set_scopes(value)

static var eventsubs : Dictionary :
	get: return get_eventsubs()
	set(value): set_eventsubs(value)


## no-OBS-ws settings
static var _obs_autoconnect: TwitchSetting.Property
static var obs_autoconnect : bool :
	get: return _obs_autoconnect.get_val()
	set(val): _obs_autoconnect.set_val(val)

static var _obs_websocket_url: TwitchSetting.Property
static var obs_websocket_url : String :
	get: return _obs_websocket_url.get_val()
	set(val): _obs_websocket_url.set_val(val)

static var _obs_websocket_port: TwitchSetting.Property
static var obs_websocket_port : int :
	get: return _obs_websocket_port.get_val()
	set(val): _obs_websocket_port.set_val(val)

static var _obs_websocket_password: TwitchSetting.Property
static var obs_websocket_password : String : #= "YvFuw8DQxdxCAsvJ":
	get: return _obs_websocket_password.get_val()
	set(val): _obs_websocket_password.set_val(val)


## RSLogger
const LOGGER_NAME_RS = "Ridiculous Stream"
const LOGGER_NAME_NOOBSWS = "OBS Websocket"
const LOGGER_NAME_SHOUTOUT = "Shoutout Manager"
const LOGGER_NAME_CUSTOM = "RSCustom"
const LOGGER_NAME_VETTING = "RSVetting"


const ALL_LOGGERS: Array[String] = [
	LOGGER_NAME_RS,
	LOGGER_NAME_NOOBSWS,
	LOGGER_NAME_SHOUTOUT,
	LOGGER_NAME_CUSTOM,
	LOGGER_NAME_VETTING,
]

static var _log_enabled: TwitchSetting.Property
static var log_enabled: Array:
	get: return get_log_enabled()


static func _static_init() -> void:
	setup()
	TwitchSetting.setup()
	set_broadcaster_id_for_all_eventsub(TwitchSetting.broadcaster_id)


static func setup():
	_auto_connect = TwitchSetting.Property.new("RidiculousStream/general/RSTwitch/auto_connect", false).as_bool().basic()
	
	_obs_autoconnect = TwitchSetting.Property.new("RidiculousStream/general/OBS Websocket/obs_autoconnect", false).as_bool().basic()
	_obs_autoconnect = TwitchSetting.Property.new("RidiculousStream/general/OBS Websocket/obs_autoconnect", false).as_bool().basic()
	_obs_websocket_url = TwitchSetting.Property.new("RidiculousStream/general/OBS Websocket/obs_websocket_url").as_str().basic()
	_obs_websocket_port = TwitchSetting.Property.new("RidiculousStream/general/OBS Websocket/obs_websocket_port", 4455).as_num().basic()
	_obs_websocket_password = TwitchSetting.Property.new("RidiculousStream/general/OBS Websocket/obs_websocket_password").as_password("Fetch the OBS web socket password from OBS").basic()
	_log_enabled = TwitchSetting.Property.new("RidiculousStream/general/logging/enabled").as_bit_field(ALL_LOGGERS as Array[String])
	
	_max_messages_in_chat = TwitchSetting.Property.new("RidiculousStream/general/Others/max_messages_in_chat", 100).as_num().basic()

static func get_log_enabled() -> Array[String]:
	var result: Array[String] = [];
	# Other classes can be initialized before the settings and use the log.
	if _log_enabled == null:
		return result;
	var bitset = _log_enabled.get_val();
	if typeof(bitset) == TYPE_STRING && bitset == "" || typeof(bitset) == TYPE_INT && bitset == 0:
		return result
	for logger_idx: int in range(ALL_LOGGERS.size()):
		var bit_value = 1 << logger_idx;
		if bitset & bit_value == bit_value:
			result.append(ALL_LOGGERS[logger_idx])
	return result

static func is_log_enabled(logger: String) -> bool:
	return log_enabled.find(logger) != -1


static func get_scopes() -> Dictionary:
	var d = {}
	for key in SCOPES_DEFAULT_DIC.keys():
		var value : int = int(ProjectSettings.get_setting(key))
		d[key] = value
	return d
static func set_scopes(values : Dictionary) -> void:
	for key in SCOPES_DEFAULT_DIC.keys():
		var value := int(values[key])
		ProjectSettings.set_setting(key, value)

static func get_eventsubs() -> Dictionary:
	var keys = []
	for property : Dictionary in ProjectSettings.get_property_list():
		var key : String = str(property.name)
		if key.begins_with("twitch/eventsub/") and ProjectSettings.get_setting(key):
			keys.append(key)
	var d = {}
	for key in keys:
		d[key] = ProjectSettings.get_setting(key)
	return d
static func set_eventsubs(values : Dictionary) -> void:
	for key in values.keys():
		var value = values[key]
		if typeof(value) in [TYPE_INT, TYPE_FLOAT]:
			value = str(value)
		ProjectSettings.set_setting(key, value)


static func to_dict() -> Dictionary:
	var d = {}
	d["app_scale"] = app_scale
	
	d["scopes"] = scopes
	d["eventsubs"] = eventsubs
	
	d["auto_connect"] = auto_connect
	
	d["obs_autoconnect"] = obs_autoconnect
	d["obs_websocket_url"] = obs_websocket_url
	d["obs_websocket_port"] = obs_websocket_port
	d["obs_websocket_password"] = obs_websocket_password
	d["log_enabled"] = log_enabled
	
	d["max_messages_in_chat"] = max_messages_in_chat
	return d

static func from_json(d: Dictionary) -> void:
	if d.has("app_scale") && d["app_scale"] != null: RSSettings.app_scale = d["app_scale"]
	
	if d.has("scopes") && d["scopes"] != null: RSSettings.scopes = d["scopes"]
	if d.has("eventsubs") && d["eventsubs"] != null: RSSettings.eventsubs = d["eventsubs"]
	
	if d.has("auto_connect") && d["auto_connect"] != null: RSSettings.auto_connect = d["auto_connect"]
	
	if d.has("obs_autoconnect") && d["obs_autoconnect"] != null: RSSettings.obs_autoconnect = d["obs_autoconnect"]
	if d.has("obs_websocket_url") && d["obs_websocket_url"] != null: RSSettings.obs_websocket_url = d["obs_websocket_url"]
	if d.has("obs_websocket_port") && d["obs_websocket_port"] != null: RSSettings.obs_websocket_port = d["obs_websocket_port"]
	if d.has("obs_websocket_password") && d["obs_websocket_password"] != null: RSSettings.obs_websocket_password = d["obs_websocket_password"]
	if d.has("log_enabled") && d["log_enabled"] != null: RSSettings.log_enabled = d["log_enabled"]
	
	if d.has("max_messages_in_chat") && d["max_messages_in_chat"] != null: RSSettings.max_messages_in_chat = d["max_messages_in_chat"]


static func set_broadcaster_id_for_all_eventsub(broadcaster_id: String):
	var all_properties : Array = ProjectSettings.get_property_list()
	var keys = []
	for d : Dictionary in all_properties:
		var key : String = str(d.name)
		if key.begins_with("twitch/eventsub/") and (
			key.ends_with("/broadcaster_user_id") or \
			key.ends_with("/moderator_user_id")
			):
			keys.append(key)
	
	for key in keys:
		if ProjectSettings.get_setting(key) == "":
			print("TwitchSetting")
			ProjectSettings.set_setting(key, broadcaster_id)
