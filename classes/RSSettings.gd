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
static func get_redeems_path() -> String: return data_dir.path_join(RS_REDEEMS_FOLDER)
static func get_obj_path() -> String: return data_dir.path_join(RS_OBJ_FOLDER)
static func get_sfx_path() -> String: return data_dir.path_join(RS_SFX_FOLDER)
static func get_logs_path() -> String: return data_dir.path_join(RS_LOG_FOLDER)
static func get_summaries_path() -> String: return data_dir.path_join(RS_SUMMARIES)

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
const RS_SUMMARIES = "summaries/"
const RS_USER_FOLDER = "users/"
const RS_REDEEMS_FOLDER = "redeems/"
const RS_OBJ_FOLDER = "obj/"
const RS_SFX_FOLDER = "sfx/"

## RS Loggers
#const LOGGER_NAME_MAIN = &"RS Main"
#const LOGGER_NAME_SETTINGS = &"RS Settings"
#const LOGGER_NAME_USER_MNG = &"RS User Manager"
#const LOGGER_NAME_LOADER = &"RS Loader"
#const LOGGER_NAME_DISPLAY = &"RS Display"
#const LOGGER_NAME_NOOBSWS = &"OBS Websocket"
#const LOGGER_NAME_SHOUTOUT = &"Shoutout Manager"
#const LOGGER_NAME_CUSTOM = &"RS Custom"
#const LOGGER_NAME_VETTING = &"RS Vetting"

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

# Twitcher settings
@export var broadcaster_id: String
@export var broadcaster_name: String
@export var client_id: String
@export var client_secret: String
@export var redirect_url: String
@export var redirect_port: int = 7170


func is_twitcher_setup() -> bool:
	if !broadcaster_id: return false
	if !client_id: return false
	if !client_secret: return false
	if !redirect_url: return false
	if !redirect_port: return false
	return true
