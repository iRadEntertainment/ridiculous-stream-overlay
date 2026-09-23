# RS manager singleton
extends Node

@onready var buffered_http_client: BufferedHTTPClient = %BufferedHTTPClient
@onready var loader: RSLoader = %RSLoader
@onready var twitcher: RSTwitcher = %RSTwitcher
@onready var user_mng: RSUserMng = %RSUserMng
@onready var no_obs_ws: NoOBSWS = %NoOBSWS
@onready var shoutout_mng: RSShoutoutMng = %RSShoutoutMng
@onready var vetting: RSVetting = %RSVetting
@onready var display: RSDisplay = %RSDisplay
@onready var summary_mng: RSSummaryMng = %RSSummaryMng

var main: RSMain
var globals := RSGlobals.new()
var settings := RSSettings.new()
var is_started := false
var _services_started := false

static var _log: TwitchLogger = TwitchLogger.new(&"RS")

signal all_started


func _ready() -> void:
	load_settings()


## Prepare application data before RSMain starts its panels and effects.
func start_services() -> void:
	if _services_started:
		return
	display.start()
	user_mng.start()
	vetting.start()
	shoutout_mng.start()
	summary_mng.start()
	_services_started = true


## Called after RSMain has wired the scene's service listeners.
func start_connections() -> void:
	if is_started:
		return
	is_started = true
	twitcher.start()
	if settings.obs_use_module:
		no_obs_ws.start()
	all_started.emit()


func load_settings() -> void:
	# settings.ini selects the data directory containing settings.tres.
	if FileAccess.file_exists(RSSettings._CONFIG_PATH):
		var error := RSSettings._config.load(RSSettings._CONFIG_PATH)
		if error == OK:
			RSSettings.data_dir = RSSettings._config.get_value("RSSettings", "data_dir", OS.get_user_data_dir())
			_log.i("Data folder: %s" % RSSettings.data_dir)
		else:
			_log.e("Failed to load global configuration from %s: %d" % [RSSettings._CONFIG_PATH, error])
	else:
		var error := RSSettings._config.save(RSSettings._CONFIG_PATH)
		if error != OK:
			_log.e("Failed to save global configuration from %s: %d" % [RSSettings._CONFIG_PATH, error])

	_log.i("Loading settings from %s..." % RSSettings.data_dir)
	settings = loader.load_settings(settings)


func save_settings() -> void:
	_log.i("Saving data dir in settings.ini...")
	RSSettings._config.set_value("RSSettings", "data_dir", RSSettings.data_dir)
	RSSettings._config.save(RSSettings._CONFIG_PATH)
	_log.i("Saving settings...")
	loader.save_settings()


func quit() -> void:
	_log.i("Exiting...")
	save_settings()
	# Standalone scenes can use RS without starting the overlay services.
	if _services_started:
		user_mng.save_all()
		summary_mng.save_current_summary()
	get_tree().quit()
