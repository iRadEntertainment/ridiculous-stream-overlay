
extends Node
class_name RSLoader

var HOST_PARSER = RegEx.create_from_string("(https://.*?)/")

static var _log: TwitchLogger = TwitchLogger.new(&"RSLoader")

var cached = {}


func load_settings(p_default: RSSettings = null) -> RSSettings:
	var path_to_settings_file := RSSettings.get_settings_filepath()
	if FileAccess.file_exists(path_to_settings_file):
		var loaded_settings = ResourceLoader.load(path_to_settings_file)
		if loaded_settings == null:
			_log.w("[load_settings] Failed to load settings or was null: %s" % [
				path_to_settings_file
			])
			return p_default

		if loaded_settings is RSSettings:
			return loaded_settings

		_log.e("[load_settings] Expected RSSettings but found %s at %s" % [
			RSUtl.get_type_string(loaded_settings),
			path_to_settings_file
		])
		return p_default
	else:
		_log.w("[load_settings] Settings file does not exist, skipping load: %s" % [
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
		_log.i("Saved settings to %s" % [path_to_settings_file])
		return
	
	_log.e("Error %d, failed to save settings to %s" % [
		result,
		path_to_settings_file
	])


func load_sfx_from_sfx_folder(sfx_name: String) -> AudioStreamOggVorbis:
	if sfx_name in cached.keys():
		return cached[sfx_name]
	var audio: AudioStream
	if ResourceLoader.exists(RSSettings.LOCAL_RES_FOLDER + sfx_name):
		audio = ResourceLoader.load(RSSettings.LOCAL_RES_FOLDER + sfx_name)
	else:
		var sfx_global_path = RSSettings.get_sfx_path()
		audio = AudioStreamOggVorbis.load_from_file(sfx_global_path+sfx_name)
	cached[sfx_name] = audio
	return audio


func load_texture_from_url(url: String, use_cached := true) -> ImageTexture:
	if url in cached.keys() and use_cached:
		return cached[url]
	
	var file_type = url.get_extension()
	if not file_type in ["png", "jpeg", "jpg", "bmp", "webp", "svg"]:
		return
	
	var request_info: BufferedHTTPClient.RequestData = RS.buffered_http_client.request(
		url,
		HTTPClient.METHOD_GET,
		{},
		""
	)
	var response_info: BufferedHTTPClient.ResponseData = await RS.buffered_http_client.wait_for_request(request_info)

	if response_info.result != HTTPRequest.Result.RESULT_SUCCESS:
		_log.e("  Request failed! (%s) | Result code: %d | Response code: %d" % [url, response_info.result, response_info.response_code])
		return null
	
	var image_buffer = response_info.response_data
	var tex_image := Image.new()
	match file_type:
		"png": tex_image.load_png_from_buffer(image_buffer)
		"jpeg", "jpg": tex_image.load_jpg_from_buffer(image_buffer)
		"bmp": tex_image.load_bmp_from_buffer(image_buffer)
		"webp": tex_image.load_webp_from_buffer(image_buffer)
		"svg": tex_image.load_svg_from_buffer(image_buffer)
		_:
			_log.e("%s format not recognised."%file_type)
			return
	if tex_image.is_empty():
		_log.w("Image %s is empty" % url)
		return
	var tex = ImageTexture.create_from_image(tex_image)
	cached[url] = tex
	return tex


func load_texture_from_data_folder(texture_file_name: String) -> Texture2D:
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
