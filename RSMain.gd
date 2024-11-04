# ================== #
#      RSMain.gd     #
# ================== #


extends Control
class_name RSMain

@onready var debug_view: Control = %debug_view

var globals := RSGlobals.new()
var http_request := HTTPRequest.new()

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

@onready var btn_floating_menu: Button = %btn_floating_menu
@onready var pnl_notifications: PanelContainer = %pnl_notifications

@onready var alert_scene : RSAlertOverlay = %alert_scene
@onready var physic_scene : RSPhysicsScene = %physics_scene

var wheel_of_random : RSWheelOfRandom

var pnls: Array[Control] = []
var known_users := {} #{ user_login: RSTwitchUser }
var unknown_users_cache := {}


# ================================ INIT ========================================
func _ready() -> void:
	print("=================================== RIDICULOS STREAMING STARTED ===================================")
	pnls = [
		%pnl_settings,
		%pnl_chat
	]
	setup_mouse_passthrough()
	load_settings()
	load_known_user()
	get_tree().root.content_scale_factor = RSSettings.app_scale
	start_everything()


func launch_game(val: bool):
	if val: %game.show()
	else: %game.hide()


func setup_mouse_passthrough():
	var ui_elements = get_all_control_nodes(self)
	ui_elements.append(%split_chat)
	for control: Control in ui_elements:
		control.add_to_group("UI")
	
	mouse_tracker.mouse_track_updated.connect(mouse_pass.SetClickThrough)
	mouse_tracker.start(self)
	mouse_pass.SetClickThrough(true)
	debug_view.start(self)


func get_all_control_nodes(node_to_search: Node, found: Array[Control] = []) -> Array[Control]:
	for child in node_to_search.get_children():
		var is_blocking := false
		if child is Window:
			continue
		if child is Control:
			if child.mouse_filter == MOUSE_FILTER_STOP:
				found.append(child)
				is_blocking = true
		if child.get_child_count() > 0 and not is_blocking:
			var new_found_nodes = get_all_control_nodes(child, found)
			found.append_array(new_found_nodes)
	return found


func start_everything():
	loader.start(self)
	twitcher.start(self)
	custom.start(self)
	vetting.start(self)
	shoutout_mng.start(self)
	no_obs_ws.start(self)
	physic_scene.start(self)
	display.start(self)
	btn_floating_menu.start(self)
	pnl_notifications.start(self)
	alert_scene.start(self)
	
	
	for pnl: Control in pnls:
		if pnl.has_method("start"):
			pnl.start(self)



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
	print("Loading settings from RSMain")
	loader.load_settings()
	
func save_settings():
	print("Saving settings from RSMain")
	loader.save_settings()


func quit():
	save_settings()
	save_known_users()
	get_tree().quit()

# =============================== UTILS =======================================
func play_sfx(which: String) -> void:
	match which:
		"quack":
			$sfx/quack.stream = load("res://local_res/sfx_quack_0%s.ogg"%randi_range(1, 2))
			$sfx/quack.play()
