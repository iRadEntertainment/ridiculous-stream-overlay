# panel RSuser List
extends PanelContainer


@onready var btn_sort: MenuButton = %btn_sort
var entries_list: Array[RSTwitchUserEntry] = []

var filter_live := false

signal user_selected(user, live_data)




func _ready() -> void:
	init_menus()


func start() -> void:
	populate_user_button_list()
	
	%pnl_loading_live.hide()
	RS.user_mng.live_streamers_updating.connect(_on_live_streamers_updating)
	RS.user_mng.live_streamers_updated.connect(_on_live_streamers_updated)
	RS.user_mng.known_users_updated.connect(_on_known_users_updated)


#region Sorting
var order_ascendant: bool = true:
	set(val):
		if order_ascendant == val: return
		order_ascendant = val
		%btn_sort.icon = preload("res://ui/icons/bootstrap_icons/sort-up.svg")\
			if order_ascendant else \
			preload("res://ui/icons/bootstrap_icons/sort-down-alt.svg")
		sort_and_update_entries()
var sort_func: Callable:
	set(val):
		sort_func = val
		sort_and_update_entries()


func sort_and_update_entries() -> void:
	if not sort_func: return
	entries_list.sort_custom(sort_func.bind(order_ascendant))
	for i: int in entries_list.size():
		var entry: RSTwitchUserEntry = entries_list[i]
		%user_list.move_child(entry, i)


func sort_by_username(a: RSTwitchUserEntry, b: RSTwitchUserEntry, ascendent: bool) -> bool:
	return a.user.username > b.user.username == ascendent
func sort_by_added_on(a: RSTwitchUserEntry, b: RSTwitchUserEntry, ascendent: bool) -> bool:
	return a.user.added_on < b.user.added_on == ascendent
func sort_by_points(a: RSTwitchUserEntry, b: RSTwitchUserEntry, ascendent: bool) -> bool:
	var a_points: int = a.user.current_global_interactions.global_points
	var b_points: int = b.user.current_global_interactions.global_points
	if a_points == b_points: return false
	return a_points < b_points == ascendent
func sort_by_games(a: RSTwitchUserEntry, b: RSTwitchUserEntry, ascendent: bool) -> bool:
	var a_games: int = a.user.steam_app_ids.size() + a.user.itchio_app_urls.size()
	var b_games: int = b.user.steam_app_ids.size() + b.user.itchio_app_urls.size()
	if a_games == b_games: return false
	return a_games < b_games == ascendent


#endregion


#region Menus
var sort_menu = [
	{
		"icon": preload("res://ui/icons/bootstrap_icons/person-heart.svg"),
		"item_name": "Name",
		"callable": _on_sort_by_name_pressed,
	},
	{
		"icon": preload("res://ui/icons/bootstrap_icons/calendar3.svg"),
		"item_name": "Added date",
		"callable": _on_sort_by_added_on_pressed,
	},
	{
		"icon": preload("res://ui/icons/bootstrap_icons/sparkles.svg"),
		"item_name": "Points",
		"callable": _on_sort_by_points_pressed,
	},
	{
		"icon": preload("res://ui/icons/bootstrap_icons/joystick.svg"),
		"item_name": "Games",
		"callable": _on_sort_by_games_pressed,
	},
]


func init_menus() -> void:
	var pop: PopupMenu = btn_sort.get_popup()
	pop.index_pressed.connect(_on_sort_menu_index_pressed)
	for i: int in sort_menu.size():
		var item_dict: Dictionary = sort_menu[i]
		var icon: Texture2D = item_dict.icon
		var item_name: String = item_dict.item_name
		pop.add_icon_item(icon, item_name)
		pop.set_item_icon_max_width(i, 24)

func _on_sort_menu_index_pressed(index: int) -> void:
	var callable: Callable = sort_menu[index].callable
	callable.call()

func _on_sort_by_name_pressed() -> void: sort_func = sort_by_username
func _on_sort_by_added_on_pressed() -> void: sort_func = sort_by_added_on
func _on_sort_by_points_pressed() -> void: sort_func = sort_by_points
func _on_sort_by_games_pressed() -> void: sort_func = sort_by_games
#endregion


func populate_user_button_list() -> void:
	%ln_filter.text = ""
	entries_list.clear()
	for btn in %user_list.get_children():
		btn.queue_free()
	
	for user_id in RS.user_mng.known.keys():
		add_user_btn_entry_from_user_id(user_id)


func add_user_btn_entry_from_user_id(user_id: int) -> void:
	var user: RSUser = RS.user_mng.known[user_id]
	if not user: return
	var btn_user_instance: RSTwitchUserEntry = RSGlobals.btn_user_pack.instantiate()
	btn_user_instance.user = user
	btn_user_instance.user_selected.connect(user_selected_pressed)
	entries_list.append(btn_user_instance)
	btn_user_instance.tree_exiting.connect(func(): entries_list.erase(btn_user_instance))
	%user_list.add_child(btn_user_instance)


func toggle_live_users(toggled_on: bool) -> void:
	for user_button in %user_list.get_children():
		user_button.visible = !toggled_on or \
				user_button.user.user_id in RS.user_mng.live_streamers_data.keys()


## Called by btn_user_instance
func user_selected_pressed(btn_user: RSUser) -> void:
	if not btn_user:
		return
	%ln_filter.text = ""
	var user: RSUser = await RS.user_mng.known.get(btn_user.user_id)
	var live_data: TwitchStream = RS.user_mng.live_streamers_data.get(btn_user.user_id)
	user_selected.emit(user, live_data)


func _on_live_streamers_updating() -> void:
	%pnl_loading_live.show()
func _on_live_streamers_updated() -> void:
	%pnl_loading_live.hide()
func _on_known_users_updated() -> void:
	var known_ids: Array = RS.user_mng.known.keys()
	for btn: RSTwitchUserEntry in %user_list.get_children():
		var user: RSUser = btn.user
		known_ids.erase(user.user_id)
		if not user.user_id in RS.user_mng.known.keys():
			btn.queue_free()
	
	for user_id: int in known_ids:
		add_user_btn_entry_from_user_id(user_id)


func _on_btn_filter_live_pressed() -> void:
	filter_live = !filter_live
	toggle_live_users(filter_live)
func _on_btn_reload_pressed() -> void:
	RS.user_mng.refresh_live_streamers()
	
func _on_ln_filter_text_changed(new_text: String) -> void:
	new_text = new_text.to_lower()
	for user_line in %user_list.get_children():
		user_line.visible = user_line.user.username.find(new_text) != -1 or new_text.is_empty()

func _on_btn_sort_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_RIGHT:
			order_ascendant = !order_ascendant
