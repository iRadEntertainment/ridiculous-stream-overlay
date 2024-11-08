@tool
extends Resource
class_name RSSettings

const _CONFIG_PATH := "user://settings.ini"
static var _config := ConfigFile.new()

static var data_dir: String = OS.get_user_data_dir():
	set(value):
		if value == data_dir: return
		if !DirAccess.dir_exists_absolute(value):
			print_verbose("Ridiculous Stream data directory does not exist and will be created: '%s'")
			if OK == DirAccess.make_dir_recursive_absolute(value):
				# Make sure the directory path ends with / or \
				if !value.ends_with("/") and !value.ends_with("\\"):
					value += "/"

				# Only change the directory if it exists and managed to be created
				data_dir = value
				_config.set_value("RSSettings", "data_dir", data_dir)
			else:
				push_error("Failed to create data directory for Ridiculous Stream: '%s'" % [value])

static var path_settings: String:
	get: return "%s/%s" % [
		data_dir,
		RS_SETTINGS_FILE_NAME
	]

# UTILITIES
static func get_settings_filepath() -> String:
	var path := "%s/%s" % [data_dir, RS_SETTINGS_FILE_NAME]
	return path
static func get_users_path() -> String:
	var path := "%s/%s" % [data_dir, RS_USER_FOLDER]
	return path
static func get_obj_path() -> String:
	var path := "%s/%s" % [data_dir, RS_OBJ_FOLDER]
	return path
static func get_sfx_path() -> String:
	var path := "%s/%s" % [data_dir, RS_SFX_FOLDER]
	return path
static func get_logs_path() -> String:
	var path := "%s/%s" % [data_dir, RS_LOG_FOLDER]
	return path

static func _static_init() -> void:
	if FileAccess.file_exists(_CONFIG_PATH):
		var error := _config.load(_CONFIG_PATH)
		if OK == error:
			data_dir = _config.get_value("RSSettings", "data_dir", OS.get_user_data_dir())
		else:
			push_error("Failed to load global configuration from %s: %d" % [_CONFIG_PATH, error])
	else:
		var error := _config.save(_CONFIG_PATH)
		if OK != _config.save(_CONFIG_PATH):
			push_error("Failed to save global configuration from %s: %d" % [_CONFIG_PATH, error])

const LOCAL_RES_FOLDER = "res://local_res/"
const RS_SETTINGS_FILE_NAME = "settings.json"
const RS_VETTING_FILE_NAME = "user_vetting_list.json"
const RS_LOG_FOLDER = "logs/"
const RS_USER_FOLDER = "users/"
const RS_OBJ_FOLDER = "obj/"
const RS_SFX_FOLDER = "sfx/"


## Uses the implicit auth flow see also: https://dev.twitch.tv/docs/authentication/getting-tokens-oauth/#implicit-grant-flow
## @deprecated use AuthorizationCodeGrantFlow...
const FLOW_IMPLICIT = "ImplicitGrantFlow";
## Uses the client credentials auth flow see also: https://dev.twitch.tv/docs/authentication/getting-tokens-oauth/#client-credentials-grant-flow
const FLOW_CLIENT_CREDENTIALS = "ClientCredentialsGrantFlow";
## Uses the auth code flow see also: https://dev.twitch.tv/docs/authentication/getting-tokens-oauth/#authorization-code-grant-flow
const FLOW_AUTHORIZATION_CODE = "AuthorizationCodeGrantFlow";
## Uses an device code and no redirect url see: https://dev.twitch.tv/docs/authentication/getting-tokens-oauth/#device-code-grant-flow
const FLOW_DEVICE_CODE_GRANT = "DeviceCodeGrantFlow";

## Twitcher Loggers
const LOGGER_NAME_AUTH = "TwitchAuthorization"
const LOGGER_NAME_EVENT_SUB = "TwitchEventSub"
const LOGGER_NAME_REST_API = "TwitchRestAPI"
const LOGGER_NAME_IRC = "TwitchIRC"
const LOGGER_NAME_IMAGE_LOADER = "TwitchImageLoader"
const LOGGER_NAME_COMMAND_HANDLING = "TwitchCommandHandling"
const LOGGER_NAME_SERVICE = "TwitchService"
const LOGGER_NAME_HTTP_CLIENT = "TwitchHttpClient"
const LOGGER_NAME_HTTP_SERVER = "TwitchHttpServer"
const LOGGER_NAME_WEBSOCKET = "TwitchWebsocket"
const LOGGER_NAME_CUSTOM_REWARDS = "TwitchCustomRewards"

## RS Loggers
const LOGGER_NAME_MAIN = "RS"
const LOGGER_NAME_NOOBSWS = "OBS Websocket"
const LOGGER_NAME_SHOUTOUT = "Shoutout Manager"
const LOGGER_NAME_CUSTOM = "RSCustom"
const LOGGER_NAME_VETTING = "RSVetting"

const ALL_LOGGERS: Array[String] = [
	LOGGER_NAME_AUTH, # Twitcher Loggers
	LOGGER_NAME_EVENT_SUB,
	LOGGER_NAME_REST_API,
	LOGGER_NAME_IRC,
	LOGGER_NAME_IMAGE_LOADER,
	LOGGER_NAME_COMMAND_HANDLING,
	LOGGER_NAME_SERVICE,
	LOGGER_NAME_HTTP_CLIENT,
	LOGGER_NAME_HTTP_SERVER,
	LOGGER_NAME_WEBSOCKET,
	LOGGER_NAME_CUSTOM_REWARDS,
	
	LOGGER_NAME_MAIN, # RS Loggers
	LOGGER_NAME_NOOBSWS,
	LOGGER_NAME_SHOUTOUT,
	LOGGER_NAME_CUSTOM,
	LOGGER_NAME_VETTING,
]

const SCOPES_DEFAULT_DIC := {
			"chat": int(0),
			"channel": int(0),
			"moderator": int(0),
			"user": int(0),
		}


# RS settings
var app_scale: float = 1.0

var auto_connect : bool = false
var max_messages_in_chat : int = 100
var eventsubs : Dictionary

# no-OBS-ws settings
var obs_autoconnect : bool
var obs_websocket_url : String
var obs_websocket_port : int
var obs_websocket_password : String

var log_enabled: Array = ALL_LOGGERS

# Twitcher settings
var authorization_flow: String = FLOW_AUTHORIZATION_CODE
var broadcaster_id: String
var client_id: String
var client_secret: String
var redirect_url: String = "http://localhost:7170"
var redirect_port: int = 7170

# var scopes : Dictionary = SCOPES_DEFAULT_DIC
var scopes: Array[String] = get_all_scopes_list()

var force_verify: String = "false"
var subscriptions: Dictionary

var image_transformers: Dictionary = {}
var image_transformer: TwitchImageTransformer


var image_tranformer_path: String = "TwitchImageTransformer"
var imagemagic_path: String
var twitch_image_cdn_host: String = "https://static-cdn.jtvnw.net"

var auth_cache: String = "user://auth.conf"
#var secret_storage: String = "user://secrets.conf"

var token_host: String = "https://id.twitch.tv"
var token_endpoint: String = "/oauth2/token"

# var fallback_texture2d: Texture2D
# var fallback_profile: Texture2D

var cache_emote: String = "user://emotes"
var cache_badge: String = "user://badge"
var cache_cheermote: String = "user://cheermote"
var use_test_server: bool = false

var eventsub_test_server_url: String = "ws://127.0.0.1:8081/ws"
var eventsub_live_server_url: String = "wss://eventsub.wss.twitch.tv/ws"

var irc_server_url: String = "wss://irc-ws.chat.twitch.tv:443"
var irc_username: String
var irc_main_channel: String
var irc_connect_to_channel: Array[StringName]
var irc_login_message: String = "Bot has successfully connected."
var irc_send_message_delay: int = 320
# var default_caps: Array[TwitchIrcCapabilities.Capability] = [TwitchIrcCapabilities.COMMANDS, TwitchIrcCapabilities.TAGS];
# var default_cap_val = TwitchIrcCapabilities.get_bit_value(default_caps);
var irc_capabilities: Array[TwitchIrcCapabilities.Capability] = [TwitchIrcCapabilities.COMMANDS, TwitchIrcCapabilities.TAGS]

var api_host: String = "https://api.twitch.tv"

var ignore_message_eventsub_in_seconds: int = 600
var http_client_min: int = 2
var http_client_max: int = 4



func is_log_enabled(logger: String) -> bool:
	return log_enabled.has(logger)


func get_scopes() -> Dictionary:
	var d = {}
	for key in SCOPES_DEFAULT_DIC.keys():
		var value : int = int(scopes[key])
		d[key] = value
	return d
func set_scopes(values : Dictionary) -> void:
	for key in SCOPES_DEFAULT_DIC.keys():
		var value := int(values[key])
		ProjectSettings.set_setting(key, value)

func get_eventsubs() -> Dictionary:
	var keys = []
	for property : Dictionary in ProjectSettings.get_property_list():
		var key : String = str(property.name)
		if key.begins_with("twitch/eventsub/") and ProjectSettings.get_setting(key):
			keys.append(key)
	var d = {}
	for key in keys:
		d[key] = ProjectSettings.get_setting(key)
	return d
func set_eventsubs(values : Dictionary) -> void:
	for key in values.keys():
		var value = values[key]
		if typeof(value) in [TYPE_INT, TYPE_FLOAT]:
			value = str(value)
		ProjectSettings.set_setting(key, value)


# func to_dict() -> Dictionary:
# 	var d = {}
# 	d["app_scale"] = app_scale
	
# 	d["scopes"] = scopes
# 	d["eventsubs"] = eventsubs
	
# 	d["auto_connect"] = auto_connect
	
# 	d["obs_autoconnect"] = obs_autoconnect
# 	d["obs_websocket_url"] = obs_websocket_url
# 	d["obs_websocket_port"] = obs_websocket_port
# 	d["obs_websocket_password"] = obs_websocket_password
# 	d["log_enabled"] = log_enabled
	
# 	d["max_messages_in_chat"] = max_messages_in_chat
# 	return d

# static func from_json(d: Dictionary) -> RSSettings:
# 	var _settings = RSSettings.new()
# 	if d.has("app_scale") && d["app_scale"] != null: _settings.app_scale = d["app_scale"]
	
# 	if d.has("scopes") && d["scopes"] != null: _settings.scopes = d["scopes"]
# 	if d.has("eventsubs") && d["eventsubs"] != null: _settings.eventsubs = d["eventsubs"]
	
# 	if d.has("auto_connect") && d["auto_connect"] != null: _settings.auto_connect = d["auto_connect"]
	
# 	if d.has("obs_autoconnect") && d["obs_autoconnect"] != null: _settings.obs_autoconnect = d["obs_autoconnect"]
# 	if d.has("obs_websocket_url") && d["obs_websocket_url"] != null: _settings.obs_websocket_url = d["obs_websocket_url"]
# 	if d.has("obs_websocket_port") && d["obs_websocket_port"] != null: _settings.obs_websocket_port = d["obs_websocket_port"]
# 	if d.has("obs_websocket_password") && d["obs_websocket_password"] != null: _settings.obs_websocket_password = d["obs_websocket_password"]
# 	if d.has("log_enabled") && d["log_enabled"] != null: _settings.log_enabled = d["log_enabled"]
	
# 	if d.has("max_messages_in_chat") && d["max_messages_in_chat"] != null: _settings.max_messages_in_chat = d["max_messages_in_chat"]
# 	return _settings


# func set_broadcaster_id_for_all_eventsub():
# 	var all_properties : Array = ProjectSettings.get_property_list()
# 	var keys = []
# 	for d : Dictionary in all_properties:
# 		var key : String = str(d.name)
# 		if key.begins_with("twitch/eventsub/") and (
# 			key.ends_with("/broadcaster_user_id") or \
# 			key.ends_with("/moderator_user_id")
# 			):
# 			keys.append(key)
	
# 	for key in keys:
# 		if ProjectSettings.get_setting(key) == "":
# 			print("TwitchSetting")
# 			ProjectSettings.set_setting(key, broadcaster_id)

func is_twitcher_setup() -> bool:
	if !broadcaster_id: return false
	if !client_id: return false
	if !client_secret: return false
	if !redirect_url: return false
	if !redirect_port: return false
	return true

# ACTIVATE ALL SCOPES ('cause I can't be fucked to do it properly) JESUS
static func get_all_scopes_list() -> Array[String]:
	var res: Array[String] = []
	for scope: TwitchScopes.Scope in TwitchScopes.get_all_scopes():
		res.append(scope.value)
	return res

#var example_for_pandino = ["chat:read", "chat:edit"]
