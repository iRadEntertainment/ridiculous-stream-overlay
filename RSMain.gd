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
@onready var twitcher: RSTwitcher = %RSTwitcher
@onready var no_obs_ws: NoOBSWS = %NoOBSWS
@onready var shoutout_mng: RSShoutoutMng = %RSShoutoutMng
@onready var custom: RSCustom = %RSCustom
@onready var vetting: RSVetting = %RSVetting
@onready var display: RSDisplay = %RSDisplay

# Control nodes
@onready var btn_floating_menu: Button = %btn_floating_menu
@onready var pnl_notifications: PanelContainer = %pnl_notifications

@onready var alert_scene : RSAlertOverlay = %alert_scene
@onready var physic_scene : RSPhysicsScene = %physics_scene

var wheel_of_random : RSWheelOfRandom

var pnls: Array[Control] = []

# Global vars
var known_users := {} #{ user_login: RSTwitchUser }
var unknown_users_cache := {}


# ================================ INIT ========================================
func _ready() -> void:
	l = RSLogger.new(RSSettings.LOGGER_NAME_MAIN)

	l.i("=================================== RIDICULOS STREAMING STARTED ===================================")
	pnls = [
		%pnl_chat,
		%pnl_settings,
		%pnl_welcome
	]
	setup_mouse_passthrough()
	load_settings()
	load_known_user()
	start_everything()


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


func start_everything():
	twitcher.start()
	custom.start()
	vetting.start()
	shoutout_mng.start()
	no_obs_ws.start()
	btn_floating_menu.start()
	physic_scene.start()
	display.start()
	pnl_notifications.start()
	alert_scene.start()
	
	
	for pnl: Control in pnls:
		if pnl.has_method("start"):
			pnl.start()



# =============================== KNOWN USERS ==================================
func load_known_user(username := ""):
	if username.is_empty():
		known_users = loader.load_all_user()
	else:
		known_users[username] = loader.load_userfile(username)
func save_known_users():
	loader.save_all_user(known_users)
func get_known_user(username : String) -> RSTwitchUser:
	var user = null
	if username in known_users.keys():
		user = known_users[username]
	return user
func user_from_username(username: String) -> RSTwitchUser:
	if username in known_users:
		return known_users[username]
	if username in unknown_users_cache:
		return unknown_users_cache[username]
	
	var user := RSTwitchUser.new()
	var t_user : TwitchUser = await twitcher.get_user(username)
	if t_user:
		user.username = t_user.login
		user.user_id = int(t_user.id)
		user.display_name = t_user.display_name
		user.twitch_chat_color = await twitcher.get_user_color(t_user.id)
		unknown_users_cache[username] = user
	return user


# ========================== LOAD/SAVE CONFIG ==================================
func load_settings():
	l.i("Loading settings...")
	var loaded_settings := loader.load_settings()
	if loaded_settings:
		settings = loaded_settings
	else:
		print_debug("No settings loaded")


func save_settings():
	l.i("Saving settings...")
	loader.save_settings()


func quit():
	l.i("Exiting...")
	save_settings()
	save_known_users()
	get_tree().quit()


# =============================== UTILS =======================================
func play_sfx(which: String) -> void:
	match which:
		"quack":
			$sfx/quack.stream = load("res://local_res/sfx_quack_0%s.ogg"%randi_range(1, 2))
			$sfx/quack.play()
