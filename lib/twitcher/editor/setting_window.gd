@tool
extends Control

const Token = preload("res://lib/twitcher/lib/oOuch/token.gd")

@onready var client_id_input: LineEdit = %ClientIdInput
@onready var client_secret_input: LineEdit = %ClientSecretInput
@onready var flow_input: OptionButton = %FlowInput
@onready var token_valid_value: Label = %TokenValidValue
@onready var refresh_token_value: CheckBox = %RefreshTokenValue
@onready var token_scope_value: TextEdit = %TokenScopeValue
@onready var reload_token: Button = %ReloadToken
@onready var remove_token: Button = %RemoveToken
@onready var clear_emotes: Button = %ClearEmotes
@onready var clear_badges: Button = %ClearBadges

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	client_id_input.text_changed.connect(_on_client_id_changed)
	client_secret_input.text_changed.connect(_on_client_secret_changed)
	flow_input.item_focused.connect(_on_flow_changed)
	flow_input.item_selected.connect(_on_flow_changed)

	client_id_input.text = RS.settings.client_id
	client_secret_input.text = RS.settings.client_secret
	_select_flow(RS.settings.authorization_flow)
	_on_reload_token()
	reload_token.pressed.connect(_on_reload_token)
	remove_token.pressed.connect(_on_remove_token)
	clear_badges.pressed.connect(_on_clear_badges)
	clear_emotes.pressed.connect(_on_clear_emotes)

func _on_reload_token() -> void:
	# Possiblity wrong when someone changes the auth settings locally
	var token = Token.new(RS.settings.auth_cache, RS.settings.client_secret)
	_show_token_info(token)

func _on_remove_token() -> void:
	DirAccess.remove_absolute(RS.settings.auth_cache)
	OS.alert("The token at (%s) was removed on the next start the token has to be fetched again." % RS.settings.auth_cache, "Succesfully removed token")
	_on_reload_token()

func _show_token_info(token: Token) -> void:
	token_valid_value.text = token.get_expiration()
	if token.is_token_valid():
		token_valid_value.add_theme_color_override(&"text", Color.GREEN)
	else:
		token_valid_value.add_theme_color_override(&"text", Color.RED)

	if token.has_refresh_token():
		refresh_token_value.text = "Available"
		refresh_token_value.button_pressed = true
	else:
		refresh_token_value.text = "Not Available"
		refresh_token_value.button_pressed = false

	token_scope_value.text = ",\n".join(token.get_scopes())

func _on_client_id_changed(new_text: String) -> void:
	RS.settings.client_id = new_text

func _on_client_secret_changed(new_text: String) -> void:
	RS.settings.client_secret = new_text

func _on_flow_changed(index: int) -> void:
	match index:
		0: RS.settings.authorization_flow = "AUTHORIZATION_CODE_FLOW"
		1: RS.settings.authorization_flow = "DEVICE_CODE_FLOW"
		2: RS.settings.authorization_flow = "IMPLICIT_FLOW"
		3: RS.settings.authorization_flow = "CLIENT_CREDENTIALS"

func _select_flow(selected_flow: String) -> void:
	match selected_flow:
		"AUTHORIZATION_CODE_FLOW": flow_input.select(0)
		"DEVICE_CODE_FLOW": flow_input.select(1)
		"IMPLICIT_FLOW": flow_input.select(2)
		"CLIENT_CREDENTIALS": flow_input.select(3)

func _on_clear_badges() -> void:
	var badge_dir = DirAccess.open(RS.settings.cache_badge);
	for file in badge_dir.get_files():
		if file.ends_with(".res"):
			badge_dir.remove(file);

func _on_clear_emotes() -> void:
	var emote_dir = DirAccess.open(RS.settings.cache_emote);
	for file in emote_dir.get_files():
		if file.ends_with(".res"):
			emote_dir.remove(file);
