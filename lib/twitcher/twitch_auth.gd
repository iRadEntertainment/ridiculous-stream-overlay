extends RefCounted

## Delegate class for the oOuch Library.
class_name TwitchAuth

## The requested devicecode to show to the user for authorization
signal device_code_requested(device_code: OAuth.OAuthDeviceCodeResponse);

## Called when the auth is ready to do auth things.
signal initialized();

var l: RSLogger = RSLogger.new(RSSettings.LOGGER_NAME_AUTH)
var auth: OAuth;
var is_initialzied: bool;
var token_handler: TwitchTokenHandler;

func _init(p_rs_settings: RSSettings = null) -> void:
	OAuth.set_logger(l.e, l.i, l.d);
	var oauth_settings = await _get_setting(p_rs_settings)
	token_handler = TwitchTokenHandler.new(oauth_settings);
	auth = OAuth.new(oauth_settings, token_handler);
	is_initialzied = true;
	initialized.emit();

func _is_initialized() -> void:
	if !is_initialzied: await initialized;

func login() -> void:
	await _is_initialized();
	await auth.login();

func validate() -> Dictionary:
	return await token_handler.validate_token()

func ensure_authentication() -> void:
	await _is_initialized();
	await auth.ensure_authentication();

func get_access_token() -> String:
	await _is_initialized();
	return await auth.get_token();

func is_authenticated() -> bool:
	await _is_initialized();
	return auth.is_authenticated();

func refresh_token() -> void:
	await _is_initialized();
	auth.refresh_token();

func _get_setting(p_rs_settings: RSSettings = null) -> OAuthSetting:
	var rs_settings: RSSettings = p_rs_settings if p_rs_settings else RS.settings
	var oauth_settings = OAuthSetting.new();
	await oauth_settings.load_from_wellknown("https://id.twitch.tv/oauth2/.well-known/openid-configuration")
	oauth_settings.device_authorization_url = "https://id.twitch.tv/oauth2/device";
	oauth_settings.authorization_flow = _get_flow();
	oauth_settings.client_id = rs_settings.client_id;
	oauth_settings.client_secret = rs_settings.client_secret;
	oauth_settings.redirect_url = rs_settings.redirect_url;
	oauth_settings.cache_file = rs_settings.auth_cache;
	oauth_settings.encryption_secret = rs_settings.client_id if rs_settings.client_secret.is_empty() else rs_settings.client_secret;
	oauth_settings.scopes = rs_settings.twitch_scopes;
	return oauth_settings;

func _get_flow() -> OAuth.AuthorizationFlow:
	return OAuth.AuthorizationFlow.get(RS.settings.authorization_flow, OAuth.AuthorizationFlow.AUTHORIZATION_CODE_FLOW) as OAuth.AuthorizationFlow;

func test(p_client_id: String, p_client_secret: String, p_redirect_uri: String, ) -> bool:
	return false
