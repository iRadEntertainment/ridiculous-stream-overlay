# ================== #
#      RSMain.gd     #
# ================== #
# Main overlay scene; application services live in the RS autoload.

extends Control
class_name RSMain

@onready var debug_view: Control = %debug_view

# Modules
@onready var mouse_tracker: RSMouseTracker = %RSMouseTracker
@onready var mouse_pass: Node = %RSMousePass # C# class
@onready var custom: RSCustom = %RSCustom

# Control nodes
@onready var btn_floating_menu: RSFloatingMenu = %btn_floating_menu
@onready var manadono_snow: ColorRect = %manadono_snow

# Panels
#@onready var pnl_welcome: PanelWelcome = %pnl_welcome
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


var is_started := false

# ================================ INIT ========================================
func _ready() -> void:
	print_rich("[color=]=================================== RIDICULOS STREAM STARTED ===================================")
	# Application settings have already been loaded by RS.
	
	setup_mouse_passthrough()
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


func start_everything() -> void:
	if is_started:
		return
	is_started = true
	await get_tree().process_frame
	get_window().always_on_top = true

	RS.start_services()
	custom.start()
	btn_floating_menu.show()
	btn_floating_menu.start()
	physic_scene.start()
	pnl_notifications.start()
	alert_scene.start()

	for pnl: Control in pnls_to_start:
		if pnl.has_method("start"):
			pnl.start()

	RS.start_connections()


## Find the containing overlay without exposing its children through RS.
## This also works for nested scene instances and dynamically added entries.
static func from_node(node: Node) -> RSMain:
	var ancestor := node.get_parent()
	while ancestor != null:
		if ancestor is RSMain:
			return ancestor as RSMain
		ancestor = ancestor.get_parent()
	return null


# =============================== UTILS =======================================
func play_sfx(
			_from_username: String = "",
			_info: TwitchCommandInfo = null,
			_args: PackedStringArray = [],
			which: String = "",
		) -> void:
	if which == "quack":
		$sfx/quack.stream = load("res://local_res/sfx_quack_0%s.ogg"%randi_range(1, 2))
		$sfx/quack.play()
		return
	
	for sfx_node: AudioStreamPlayer in %sfx.get_children():
		if sfx_node.name == which:
			sfx_node.play()
			break
