extends Resource

class_name OOuchToken

## Wrapper for the tokens. Hint never store the token value as string in
## your code to reduce the chance to dox the tokens always use the getter.

@export var _scopes: PackedStringArray = [];
@export var _expire_date: int;
@export var _cache_file: String;

var _config_file: ConfigFile = ConfigFile.new();
var _access_token: String = "";
var _refresh_token: String = "";
var _encryption_secret: String;

func _init(cache_file: String, encryption_secret: String) -> void:
	_cache_file = cache_file;
	_encryption_secret = encryption_secret;
	_load_tokens();

func update_values(access_token: String, refresh_token: String, expire_in: int, scopes: Array[String]):
	_expire_date = roundi(Time.get_unix_time_from_system() + expire_in);
	_access_token = access_token;
	_refresh_token = refresh_token;
	_scopes = scopes;
	_persist_tokens();

## Persists the tokesn with the expire date
func _persist_tokens():
	_config_file.set_value("auth", "expire_date", _expire_date);
	_config_file.set_value("auth", "access_token", _access_token);
	_config_file.set_value("auth", "refresh_token", _refresh_token);
	_config_file.set_value("auth", "scopes", ",".join(_scopes));
	_config_file.save_encrypted_pass(_cache_file, _encryption_secret);

## Loads the tokens and returns the information if the file got created
func _load_tokens():
	print("[_load_tokens] %s" % [_cache_file])
	var status = _config_file.load_encrypted_pass(_cache_file, _encryption_secret)
	if status == OK:
		_expire_date = _config_file.get_value("auth", "expire_date", 0);
		_access_token = _config_file.get_value("auth", "access_token");
		_refresh_token = _config_file.get_value("auth", "refresh_token");
		_scopes = _config_file.get_value("auth", "scopes", "").split(",");
		return true;
	return false;

func get_refresh_token() -> String: return _refresh_token;
func get_access_token() -> String: return _access_token;
func get_scopes() -> PackedStringArray: return _scopes;
func get_expiration() -> String: return Time.get_datetime_string_from_unix_time(_expire_date)

func invalidate() -> void:
	_expire_date = 0;
	_refresh_token = "";
	_access_token = ""
	_scopes = [];

func has_refresh_token() -> bool:
	return _refresh_token != "";

func is_token_valid() -> bool:
	var current_time = Time.get_unix_time_from_system();
	return current_time < _expire_date;
