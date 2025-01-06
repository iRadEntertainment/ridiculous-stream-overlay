@tool
extends Resource
class_name RSSettings

const _CONFIG_PATH := "user://settings.ini"
static var _config := ConfigFile.new()

static var data_dir: String = OS.get_user_data_dir():
	set(value):
		if value == data_dir: return
		if !value.is_absolute_path():
			push_error("Failed to assign data directory for Ridiculous Stream: '%s'" % [value])
			return
		if !DirAccess.dir_exists_absolute(value):
			print_verbose("Ridiculous Stream data directory does not exist and will be created: '%s'")
			if OK == DirAccess.make_dir_recursive_absolute(value):
				# Only change the directory if it exists and managed to be created
				data_dir = value
				_config.set_value("RSSettings", "data_dir", data_dir)
				_config.save(_CONFIG_PATH)
			else:
				push_error("Failed to create data directory for Ridiculous Stream: '%s'" % [value])
		else:
			data_dir = value
			_config.set_value("RSSettings", "data_dir", data_dir)
			_config.save(_CONFIG_PATH)


# UTILITIES
static func get_settings_filepath() -> String: return data_dir.path_join(RS_SETTINGS_FILE_NAME)
static func get_users_path() -> String: return data_dir.path_join(RS_USER_FOLDER)
static func get_obj_path() -> String: return data_dir.path_join(RS_OBJ_FOLDER)
static func get_sfx_path() -> String: return data_dir.path_join(RS_SFX_FOLDER)
static func get_logs_path() -> String: return data_dir.path_join(RS_LOG_FOLDER)

static var project_settings_twitch_publish: bool:
	get: return ProjectSettings.get_setting("ridiculous_stream/twitch/publish", false)

static var project_settings_twitch_client_id: String:
	get: return ProjectSettings.get_setting("ridiculous_stream/twitch/client_id", "")

static var project_settings_twitch_redirect_uri: String:
	get: return ProjectSettings.get_setting("ridiculous_stream/twitch/redirect_uri", "http://localhost:7170")

static var project_settings_twitch_grant_type: OAuth.AuthorizationFlow:
	get:
		var default_grant_type := OAuth.AuthorizationFlow.AUTHORIZATION_CODE_FLOW
		if project_settings_twitch_publish:
			default_grant_type = OAuth.AuthorizationFlow.IMPLICIT_FLOW

		var default_grant_type_key := OAuth.AuthorizationFlow.keys()[default_grant_type] as String
		var grant_type_key := ProjectSettings.get_setting(
			"ridiculous_stream/twitch/grant_type",
			default_grant_type_key
		) as String
		var grant_type := OAuth.AuthorizationFlow.get(
			grant_type_key,
			default_grant_type
		) as OAuth.AuthorizationFlow
		return grant_type


const LOCAL_RES_FOLDER = "res://local_res/"
const RS_SETTINGS_FILE_NAME = "settings.tres"
const RS_VETTING_FILE_NAME = "user_vetting_list.json"
const RS_LOG_FOLDER = "logs/"
const RS_USER_FOLDER = "users/"
const RS_OBJ_FOLDER = "obj/"
const RS_SFX_FOLDER = "sfx/"

## Twitcher Loggers
const LOGGER_NAME_AUTH = &"TwitchAuthorization"
const LOGGER_NAME_EVENT_SUB = &"TwitchEventSub"
const LOGGER_NAME_REST_API = &"TwitchRestAPI"
const LOGGER_NAME_IRC = &"TwitchIRC"
const LOGGER_NAME_IMAGE_LOADER = &"TwitchImageLoader"
const LOGGER_NAME_COMMAND_HANDLING = &"TwitchCommandHandling"
const LOGGER_NAME_SERVICE = &"TwitchService"
const LOGGER_NAME_HTTP_CLIENT = &"TwitchHttpClient"
const LOGGER_NAME_HTTP_SERVER = &"TwitchHttpServer"
const LOGGER_NAME_WEBSOCKET = &"TwitchWebsocket"
const LOGGER_NAME_CUSTOM_REWARDS = &"TwitchCustomRewards"

## RS Loggers
const LOGGER_NAME_MAIN = &"RS Main"
const LOGGER_NAME_SETTINGS = &"RS Settings"
const LOGGER_NAME_USER_MNG = &"RS User Manager"
const LOGGER_NAME_LOADER = &"RS Loader"
const LOGGER_NAME_DISPLAY = &"RS Display"
const LOGGER_NAME_NOOBSWS = &"OBS Websocket"
const LOGGER_NAME_SHOUTOUT = &"Shoutout Manager"
const LOGGER_NAME_CUSTOM = &"RS Custom"
const LOGGER_NAME_VETTING = &"RS Vetting"

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
	LOGGER_NAME_SETTINGS,
	LOGGER_NAME_USER_MNG,
	LOGGER_NAME_LOADER,
	LOGGER_NAME_DISPLAY,
	LOGGER_NAME_NOOBSWS,
	LOGGER_NAME_SHOUTOUT,
	LOGGER_NAME_CUSTOM,
	LOGGER_NAME_VETTING,
]

@export var welcome_version: String = &""

@export var twitch_features_enabled: Array[String] = []
@export var twitch_scopes: Array[String] = []

# RS settings
@export var app_scale: float = 1.0
@export var welcome_display_always := true
@export var debug_mode := false

@export var auto_connect : bool = false
@export var max_messages_in_chat : int = 100

# no-OBS-ws settings
@export var obs_use_module := true
@export var obs_autoconnect : bool
@export var obs_websocket_url : String
@export var obs_websocket_port : int
@export var obs_websocket_password : String

@export var log_enabled: Array = ALL_LOGGERS

# Twitcher settings
@export var authorization_flow: String
@export var broadcaster_id: String
@export var broadcaster_name: String
@export var client_id: String
@export var client_secret: String
@export var redirect_url: String
@export var redirect_port: int = 7170

@export var force_verify: String = "false"
var subscriptions: Dictionary:
	get:
		return get_subscriptions_from_enabled_features()

@export var image_transformers: Dictionary = {}
var image_transformer: TwitchImageTransformer


@export var image_tranformer_path: String = "TwitchImageTransformer"
@export var imagemagic_path: String
@export var twitch_image_cdn_host: String = "https://static-cdn.jtvnw.net"

@export var auth_cache: String = "user://auth.conf"
#var secret_storage: String = "user://secrets.conf"

@export var token_host: String = "https://id.twitch.tv"
@export var token_endpoint: String = "/oauth2/token"

@export var fallback_texture2d: Texture2D
# @export var fallback_profile: Texture2D

@export var cache_emote: String = "user://emotes"
@export var cache_badge: String = "user://badge"
@export var cache_cheermote: String = "user://cheermote"
@export var use_test_server: bool = false

@export var eventsub_test_server_url: String = "ws://127.0.0.1:8081/ws"
@export var eventsub_live_server_url: String = "wss://eventsub.wss.twitch.tv/ws"

@export var chatbot_enabled := false
@export var chatbot_use_eventsub := false
@export var chatbot_username: String
@export var chatbot_user_id: String
@export var chatbot_join_message: String
@export var chatbot_channel: String
@export var chatbot_additional_channels: Array[String] = []
@export var chatbot_send_message_delay := 320 # ms

var chatbot_channels: Array[String]:
	get:
		var channels: Array[String] = [];
		if !chatbot_channel.is_empty():
			channels.append(chatbot_channel);
		if !chatbot_additional_channels.is_empty():
			channels.append_array(chatbot_additional_channels);
		return channels;

@export var irc_server_url: String = "wss://irc-ws.chat.twitch.tv:443"

# TODO: Figure out if this should be exported, or if Capability needs to be made into a Resource
#var default_caps: Array[TwitchIrcCapabilities.Capability] = [TwitchIrcCapabilities.COMMANDS, TwitchIrcCapabilities.TAGS];
#var default_cap_val = TwitchIrcCapabilities.get_bit_value(default_caps);
var irc_capabilities: Array[TwitchIrcCapabilities.Capability] = [
	TwitchIrcCapabilities.COMMANDS,
	TwitchIrcCapabilities.MEMBERSHIP,
	TwitchIrcCapabilities.TAGS,
]

@export var api_host: String = "https://api.twitch.tv"

@export var ignore_message_eventsub_in_seconds: int = 600
@export var http_client_min: int = 2
@export var http_client_max: int = 4



func is_log_enabled(logger: String) -> bool:
	return log_enabled.has(logger)


func is_twitcher_setup() -> bool:
	if !broadcaster_id: return false
	if !client_id: return false
	if !client_secret: return false
	if !redirect_url: return false
	if !redirect_port: return false
	return true


## Return the subscribed subscriptions key = TwitchSubscriptions.Subscription, value = Dictionary with conditions (ready to use)
func get_subscriptions_from_enabled_features() -> Dictionary:
	var result = {}
	for subscription: TwitchSubscriptions.Subscription in TwitchSubscriptions.get_all():
		if twitch_features_enabled.has(subscription.value):
			var conditions: Array[String] = subscription.conditions
			result[subscription] = get_conditions(conditions)
	return result


## Returns the conditions that the eventsub subscriptions need to pass to the Twitcher library
## For Ridiculous Stream we will override all the bradcaster user id with the current one
## eg. {broadcaster_user_id (String): current user id value (String)}
func get_conditions(conditions: Array[String]) -> Dictionary:
	var condition: Dictionary = {}
	for condition_name: String in conditions:
		if condition_name in ["broadcaster_user_id", "moderator_user_id", "to_broadcaster_user_id"]:
			condition[condition_name] = RS.settings.broadcaster_id
	return condition
