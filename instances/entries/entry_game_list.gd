extends PanelContainer
class_name EntryGameList

var main: RSMain:
	get: return RS.main

const ICONS = [
	preload("res://ui/icons/bootstrap_icons/steam.png"),
	preload("res://lib/games_info/itchio_icon.svg"),
]

enum Type {STEAM, ITCHIO}
var type: Type
#var user: RSUser
var steam_app_id: int
var itchio_app_url: String

var steam_data: SteamAppData
var itchio_data: ItchIOAppData
var _image_request := 0

signal game_info_steam_pressed(steam_data: SteamAppData)
signal game_info_itchio_pressed(itchio_data: ItchIOAppData)
signal entry_deleted(entry: EntryGameList)
signal game_data_refreshed(entry: EntryGameList, data: Resource)


func _ready() -> void:
	populate()


func populate() -> void:
	_image_request += 1
	var request := _image_request
	var image_url: String
	%btn_open_link.icon = ICONS[int(type)]
	match type:
		Type.STEAM:
			if not steam_data:
				return
			%btn_game_name.text = steam_data.name
			image_url = steam_data.header_image.split("?")[0]
		Type.ITCHIO:
			if not itchio_data:
				return
			%btn_game_name.text = itchio_data.title
			image_url = itchio_data.cover_image
	if image_url.is_empty():
		%bg_img.texture = null
		return
	var texture: Texture2D = await RS.loader.load_texture_from_url(image_url)
	if request == _image_request and is_inside_tree() and not is_queued_for_deletion():
		%bg_img.texture = texture


#region Inspector Signals
func _on_btn_reload_pressed() -> void:
	if $hb/btn_reload.disabled:
		return
	$hb/btn_reload.disabled = true
	$hb/btn_reload.tooltip_text = "Retrieving game info..."
	var data: Resource
	match type:
		Type.STEAM:
			data = await $SteamService.get_steam_app_data(steam_app_id)
			if data != null and data.steam_app_id != steam_app_id:
				data = null
		Type.ITCHIO:
			data = await $ItchIOService.get_itch_app_data(itchio_app_url)
			if data != null and (data.url.is_empty() or (itchio_data != null and itchio_data.id > 0 and data.id != itchio_data.id)):
				data = null
	if not is_inside_tree() or is_queued_for_deletion():
		return
	$hb/btn_reload.disabled = false
	if data == null:
		$hb/btn_reload.tooltip_text = "Could not retrieve game info. Previous data was kept. Click to retry."
		return
	$hb/btn_reload.tooltip_text = "Refresh game info"
	# The owning panel saves the association before replacing the displayed data.
	game_data_refreshed.emit(self, data)
func _on_btn_game_name_pressed() -> void:
	match type:
		Type.STEAM: game_info_steam_pressed.emit(steam_data)
		Type.ITCHIO: game_info_itchio_pressed.emit(itchio_data)
func _on_btn_promote_pressed() -> void:
	var msg: String = "Check out {title} by {developer}! {description} {link}"
	var title: String
	var developer: String
	var description: String
	var link: String
	match type:
		Type.STEAM:
			title = steam_data.name
			developer = steam_data.developers.front() if not steam_data.developers.is_empty() else "the developer"
			description = steam_data.short_description
			link = steam_data.s_team_url
		Type.ITCHIO:
			title = itchio_data.title
			developer = str(itchio_data.authors.front().get("name", "the developer")) if not itchio_data.authors.is_empty() else "the developer"
			description = itchio_data.description.left(200) + "..."
			link = itchio_data.url
	msg = msg.format(
		{
			"title": title,
			"developer": developer,
			"description": description,
			"link": link,
		}
	)
	RS.twitcher.chat(msg)
func _on_btn_open_link_pressed() -> void:
	var link: String
	match type:
		Type.STEAM: link = "https://s.team/a/%d" % steam_app_id
		Type.ITCHIO: link = itchio_app_url
	OS.shell_open(link)
	main.pnl_settings.hide()
func _on_btn_delete_pressed() -> void:
	entry_deleted.emit(self)
#endregion
