# ================== #
#      RSMain.gd     #
# ================== #
# Singleton "RS"

extends Control
class_name RSMain

@onready var debug_view: Control = %debug_view

var globals := RSGlobals.new()
var settings := RSSettings.new()
var l: RSLogger

# Modules
@onready var mouse_tracker: RSMouseTracker = %RSMouseTracker
@onready var mouse_pass: Node = %RSMousePass # C# class
@onready var loader: RSLoader = %RSLoader
@onready var user_mng: RSUserMng = %RSUserMng
@onready var twitcher: RSTwitcher = %RSTwitcher
@onready var no_obs_ws: NoOBSWS = %NoOBSWS
@onready var shoutout_mng: RSShoutoutMng = %RSShoutoutMng
@onready var custom: RSCustom = %RSCustom
@onready var vetting: RSVetting = %RSVetting
@onready var display: RSDisplay = %RSDisplay
@onready var summary_mng: RSSummaryMng = %RSSummaryMng

# Control nodes
@onready var btn_floating_menu: RSFloatingMenu = %btn_floating_menu
@onready var manadono_snow: ColorRect = %manadono_snow

# Panels
@onready var pnl_welcome: PanelWelcome = %pnl_welcome
@onready var pnl_notifications: PanelContainer = %pnl_notifications
@onready var pnl_chat: RSPnlChat = %pnl_chat
@onready var pnl_settings: RSPnlSettings = %pnl_settings
@onready var pnl_summary: PnlSummary = %pnl_summary
@onready var alert_scene: RSAlertOverlay = %alert_scene
@onready var physic_scene: RSPhysicsScene = %physics_scene

var wheel_of_random: RSWheelOfRandom

@onready var pnls_to_start: Array[Control] = [
	pnl_chat,
	pnl_settings,
	pnl_summary,
	#pnl_welcome,
]


signal all_started

# ================================ INIT ========================================
func _ready() -> void:
	print("=================================== RIDICULOS STREAM STARTED ===================================")
	l = RSLogger.new(RSSettings.LOGGER_NAME_MAIN)
	load_settings()
	await welcome_panel_check()
	
	setup_mouse_passthrough()
	start_everything()


func welcome_panel_check() -> void:
	if pnl_welcome.should_show():
		get_window().always_on_top = false
		RSUtl.fit_and_center_window_to_display(get_window())
		btn_floating_menu.hide()
		pnl_welcome.start()
		await pnl_welcome.completed
		settings.welcome_version = ProjectSettings.get_setting("application/config/version")
		save_settings()
	
	pnl_welcome.hide()


func setup_mouse_passthrough():
	var ui_elements = get_all_control_nodes(self)
	ui_elements.append(%split_chat)
	for control: Control in ui_elements:
		control.add_to_group("UI")
	mouse_tracker.mouse_track_updated.connect(mouse_pass.SetClickThrough)
	mouse_tracker.start()
	mouse_pass.SetClickThrough(true)
	debug_view.start()


func get_all_control_nodes(node_to_search: Node, found: Array[Control] = []) -> Array[Control]:
	for child in node_to_search.get_children():
		var is_blocking := false
		if child is Control:
			if child.mouse_filter == MOUSE_FILTER_STOP:
				found.append(child)
				is_blocking = true
		# if the current node doesn't blocks the mouse, search children recursive
		if child.get_child_count() > 0 and not is_blocking:
			var new_found_nodes = get_all_control_nodes(child, found)
			found.append_array(new_found_nodes)
	return found


func start_everything() -> void:
	await Engine.get_main_loop().process_frame
	get_window().always_on_top = true
	
	display.start()

	btn_floating_menu.show()

	twitcher.start()
	user_mng.start()
	custom.start()
	vetting.start()
	shoutout_mng.start()
	if settings.obs_use_module:
		no_obs_ws.start()
	btn_floating_menu.start()
	physic_scene.start()
	pnl_notifications.start()
	alert_scene.start()
	summary_mng.start()
	
	for pnl: Control in pnls_to_start:
		if pnl.has_method("start"):
			pnl.start()
	
	all_started.emit()


# ========================== LOAD/SAVE CONFIG ==================================
func load_settings():
	# The config file is stored into user:// and only holds the custom data directory
	# where everything else is stored
	if FileAccess.file_exists(RSSettings._CONFIG_PATH):
		var error := RSSettings._config.load(RSSettings._CONFIG_PATH)
		if OK == error:
			RSSettings.data_dir = RSSettings._config.get_value("RSSettings", "data_dir", OS.get_user_data_dir())
			l.i("Data folder: %s" %RSSettings.data_dir)
		else:
			l.e("Failed to load global configuration from %s: %d" % [RSSettings._CONFIG_PATH, error])
	else:
		var error := RSSettings._config.save(RSSettings._CONFIG_PATH)
		if OK != RSSettings._config.save(RSSettings._CONFIG_PATH):
			l.e("Failed to save global configuration from %s: %d" % [RSSettings._CONFIG_PATH, error])

	l.i("Loading settings from %s..." % RSSettings.data_dir)
	settings = loader.load_settings(settings)
	HttpClientManager.client_max = settings.http_client_max
	HttpClientManager.client_min = settings.http_client_min

func save_settings():
	l.i("Saving data dir in settings.ini...")
	RSSettings._config.set_value("RSSettings", "data_dir", RSSettings.data_dir)
	RSSettings._config.save(RSSettings._CONFIG_PATH)
	l.i("Saving settings...")
	loader.save_settings()

func quit():
	l.i("Exiting...")

	# Don't save anything if we haven't finished configuring, the settings may be in a bad state
	if !pnl_welcome.should_show():
		save_settings()
		user_mng.save_all()
		summary_mng.save_summary()
	
	get_tree().quit()


# =============================== UTILS =======================================
func play_sfx(which: String) -> void:
	if which == "quack":
		$sfx/quack.stream = load("res://local_res/sfx_quack_0%s.ogg"%randi_range(1, 2))
		$sfx/quack.play()
		return
	
	for sfx_node: AudioStreamPlayer in %sfx.get_children():
		if sfx_node.name == which:
			sfx_node.play()
			break
