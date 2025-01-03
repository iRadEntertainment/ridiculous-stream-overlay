
extends Node
class_name RSLoader

var HOST_PARSER = RegEx.create_from_string("(https://.*?)/")

var l := RSLogger.new(RSSettings.LOGGER_NAME_LOADER)

var cached = {}

func load_settings(p_default: RSSettings = null) -> RSSettings:
	var path_to_settings_file := RSSettings.get_settings_filepath()
	if FileAccess.file_exists(path_to_settings_file):
		var loaded_settings = ResourceLoader.load(path_to_settings_file)
		if loaded_settings == null:
			l.w("[load_settings] Failed to load settings or was null: %s" % [
				path_to_settings_file
			])
			return p_default

		if loaded_settings is RSSettings:
			return loaded_settings

		l.e("[load_settings] Expected RSSettings but found %s at %s" % [
			RSUtl.get_type_string(loaded_settings),
			path_to_settings_file
		])
		return p_default
	else:
		l.w("[load_settings] Settings file does not exist, skipping load: %s" % [
			path_to_settings_file
		])
		save_settings(RS.settings)
		return p_default

func save_settings(p_settings: RSSettings = null) -> void:
	var path_to_settings_file := RSSettings.get_settings_filepath()
	var result := ResourceSaver.save(
		RS.settings if p_settings == null else p_settings,
		path_to_settings_file
	)

	if result == OK:
		l.i("Saved settings to %s" % [path_to_settings_file])
		return
	
	l.e("Error %d, failed to save settings to %s" % [
		result,
		path_to_settings_file
	])

func load_sfx_from_sfx_folder(sfx_name : String) -> AudioStreamOggVorbis:
	if sfx_name in cached.keys():
		return cached[sfx_name]
	var audio : AudioStream
	if ResourceLoader.exists(RSSettings.LOCAL_RES_FOLDER + sfx_name):
		audio = ResourceLoader.load(RSSettings.LOCAL_RES_FOLDER + sfx_name)
	else:
		var sfx_global_path = RSSettings.get_sfx_path()
		audio = AudioStreamOggVorbis.load_from_file(sfx_global_path+sfx_name)
	cached[sfx_name] = audio
	return audio


func load_texture_from_url(url : String, use_cached := true) -> ImageTexture:
	if url in cached.keys() and use_cached:
		return cached[url]
	var file_type = url.get_extension()
	if not file_type in ["png", "jpeg", "jpg", "bmp", "webp", "svg"]: return
	var host_result : RegExMatch = HOST_PARSER.search(url)
	var host = host_result.get_string(1)
	var client := HttpClientManager.get_client(host)
	var request := client.request(url, HTTPClient.METHOD_GET, BufferedHTTPClient.HEADERS, "")
	var response := await client.wait_for_request(request)
	var image_buffer = response.response_data
	var tex_image := Image.new()
	match file_type:
		"png": tex_image.load_png_from_buffer(image_buffer)
		"jpeg", "jpg": tex_image.load_jpg_from_buffer(image_buffer)
		"bmp": tex_image.load_bmp_from_buffer(image_buffer)
		"webp": tex_image.load_webp_from_buffer(image_buffer)
		"svg": tex_image.load_svg_from_buffer(image_buffer)
		_:
			l.e("%s format not recognised."%file_type)
			return
	
	var tex = ImageTexture.create_from_image(tex_image)
	cached[url] = tex
	return tex


func load_texture_from_data_folder(texture_file_name : String) -> Texture2D:
	if texture_file_name in cached.keys():
		return cached[texture_file_name]
	var tex
	
	if ResourceLoader.exists(RSSettings.LOCAL_RES_FOLDER + texture_file_name):
		tex = ResourceLoader.load(RSSettings.LOCAL_RES_FOLDER + texture_file_name)
		
	else:
		var tex_path = RSSettings.get_obj_path()+texture_file_name
		var tex_image = Image.load_from_file(tex_path)
		tex = ImageTexture.create_from_image(tex_image)
	cached[texture_file_name] = tex
	return tex

#=========================================== USERSERSRESWRES ========================================================
func load_userfile(username) -> RSTwitchUser:
	var path := get_user_filepath(username)
	if !FileAccess.file_exists(path):
		l.i("Cannot find file: %s" % path)
	var user := RSTwitchUser.from_json(RSUtl.load_json(path))
	if user.username == "":
		user.username = username_from_userfile(path)
		l.w("%s doesn't contain a username." % path.get_file())
	return user
func save_userfile(user : RSTwitchUser) -> void:
	if user.username == "":
		l.w("cannot save an user without a username")
		return
	var path = get_user_filepath(user.username)
	var dict = user.to_dict()
	if not dict.is_empty():
		RSUtl.save_to_json(path, dict)


func load_all_user() -> Dictionary:
	var dic = {}
	var user_files = RSUtl.list_file_in_folder(RSSettings.get_users_path(), ["json"])
	
	for user_file in user_files:
		var username = username_from_userfile(user_file)
		var res := load_userfile(username)
		dic[username] = res
	
	return dic
func save_all_user(dic):
	for username in dic:
		var user := dic[username] as RSTwitchUser
		save_userfile(user)


static func userfile_from_username(username : String) -> String:
	return "user_%s.json" % username
static func username_from_userfile(userfile : String) -> String:
	userfile = userfile.get_file()
	return userfile.trim_prefix("user_").trim_suffix(".json")
static func get_user_filepath(username : String) -> String:
	var user_file = "user_%s.json" % username
	return RSSettings.get_users_path() + user_file
