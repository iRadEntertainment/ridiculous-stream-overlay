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


func _init() -> void:
	OAuth.set_logger(l.e, l.i, l.d);
	var settings = await _get_setting()
	auth = OAuth.new(settings, TwitchTokenHandler.new(settings));
	is_initialzied = true;
	initialized.emit();

func _is_initialized() -> void:
	if !is_initialzied: await initialized;

func login() -> void:
	await _is_initialized();
	await auth.login();

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

func _get_setting() -> OAuthSetting:
	var setting = OAuthSetting.new();
	await setting.load_from_wellknown("https://id.twitch.tv/oauth2/.well-known/openid-configuration")
	setting.device_authorization_url = "https://id.twitch.tv/oauth2/device";
	setting.authorization_flow = _get_flow();
	setting.client_id = RS.settings.client_id;
	setting.client_secret = RS.settings.client_secret;
	setting.redirect_url = RS.settings.redirect_url;
	setting.cache_file = RS.settings.auth_cache;
	setting.encryption_secret = RS.settings.client_secret;
	setting.scopes = RS.settings.get_scopes();
	return setting;

func _get_flow() -> OAuth.AuthorizationFlow:
	match RS.settings.authorization_flow:
		RSSettings.FLOW_AUTHORIZATION_CODE: return OAuth.AuthorizationFlow.AUTHORIZATION_CODE_FLOW;
		RSSettings.FLOW_CLIENT_CREDENTIALS: return OAuth.AuthorizationFlow.CLIENT_CREDENTIALS;
		RSSettings.FLOW_DEVICE_CODE_GRANT: return OAuth.AuthorizationFlow.DEVICE_CODE_FLOW;
		RSSettings.FLOW_IMPLICIT: return OAuth.AuthorizationFlow.IMPLICIT_FLOW;
	return OAuth.AuthorizationFlow.AUTHORIZATION_CODE_FLOW;
