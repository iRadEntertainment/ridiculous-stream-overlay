extends PanelContainer
class_name EntryGameList

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

signal game_info_steam_pressed(steam_data: SteamAppData)
signal game_info_itchio_pressed(itchio_data: ItchIOAppData)
signal entry_deleted(entry: EntryGameList)


func _ready() -> void:
	populate()


func populate() -> void:
	%btn_open_link.icon = ICONS[int(type)]
	match type:
		Type.STEAM:
			if not steam_data:
				steam_data = await $SteamService.get_steam_app_data(steam_app_id)
			%btn_game_name.text = steam_data.name
			var url_no_query: String = steam_data.header_image.split("?")[0]
			%bg_img.texture = await RS.loader.load_texture_from_url(url_no_query)
		Type.ITCHIO:
			if not itchio_data:
				itchio_data = await $ItchIOService.get_itch_app_data(itchio_app_url)
			%btn_game_name.text = itchio_data.title
			var url: String = itchio_data.cover_image
			%bg_img.texture = await RS.loader.load_texture_from_url(url)


#region Inspector Signals
func _on_btn_reload_pressed() -> void:
	match type:
		Type.STEAM:
			steam_data = await $SteamService.get_steam_app_data(steam_app_id)
			populate()
			game_info_steam_pressed.emit(steam_data)
		Type.ITCHIO:
			itchio_data = await $ItchIOService.get_itch_app_data(itchio_app_url)
			populate()
			game_info_itchio_pressed.emit(itchio_data)
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
			developer = steam_data.developers.front()
			description = steam_data.short_description
			link = steam_data.s_team_url
		Type.ITCHIO:
			title = itchio_data.title
			developer = itchio_data.authors.front()["name"]
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
	RS.pnl_settings.hide()
func _on_btn_delete_pressed() -> void:
	queue_free()
#endregion
