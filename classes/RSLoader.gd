extends Node
class_name RSLoader

const _IMG_SUPPORTED_EXT := ["png", "jpeg", "jpg", "bmp", "webp", "svg"]

var HOST_PARSER = RegEx.create_from_string("(https://.*?)/")
static var _log: TwitchLogger = TwitchLogger.new(&"RSLoader")

var texture_cache: Dictionary[String, Texture2D] = {}
var audio_cache: Dictionary[String, AudioStream] = {}
var _profile_pic_cache_dir: String:
	get: return RSSettings.get_profile_pics_path()


func load_settings(p_default: RSSettings = null) -> RSSettings:
	var path_to_settings_file := RSSettings.get_settings_filepath()
	if FileAccess.file_exists(path_to_settings_file):
		var loaded_settings = ResourceLoader.load(path_to_settings_file)
		if loaded_settings == null:
			_log.w("[load_settings] Failed to load settings or was null: %s" % [path_to_settings_file])
			return p_default
		if loaded_settings is RSSettings:
			return loaded_settings
		_log.e("[load_settings] Expected RSSettings but found %s at %s" % [RSUtl.get_type_string(loaded_settings), path_to_settings_file])
		return p_default
	else:
		_log.w("[load_settings] Settings file does not exist, skipping load: %s" % [path_to_settings_file])
		save_settings(RS.settings)
		return p_default


func save_settings(p_settings: RSSettings = null) -> void:
	var path_to_settings_file := RSSettings.get_settings_filepath()
	var result := ResourceSaver.save(RS.settings if p_settings == null else p_settings, path_to_settings_file)
	if result == OK:
		_log.i("Saved settings to %s" % [path_to_settings_file])
		return
	_log.e("Error %d, failed to save settings to %s" % [result, path_to_settings_file])


func load_sfx_from_sfx_folder(sfx_name: String) -> AudioStream:
	if audio_cache.has(sfx_name):
		return audio_cache[sfx_name]
	var audio: AudioStream
	if ResourceLoader.exists(RSSettings.LOCAL_RES_FOLDER + sfx_name):
		audio = ResourceLoader.load(RSSettings.LOCAL_RES_FOLDER + sfx_name)
	else:
		var sfx_global_path = RSSettings.get_sfx_path()
		audio = AudioStreamOggVorbis.load_from_file(sfx_global_path + sfx_name)
	audio_cache[sfx_name] = audio
	return audio


func load_texture_from_url(url: String, use_cached := true) -> ImageTexture:
	if use_cached and texture_cache.has(url):
		return texture_cache[url] as ImageTexture
	
	var file_type := url.get_extension().to_lower()
	if not _IMG_SUPPORTED_EXT.has(file_type):
		return null
	
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
	
	var image_buffer: PackedByteArray = response_info.response_data
	var tex_image := Image.new()
	match file_type:
		"png": tex_image.load_png_from_buffer(image_buffer)
		"jpeg", "jpg": tex_image.load_jpg_from_buffer(image_buffer)
		"bmp": tex_image.load_bmp_from_buffer(image_buffer)
		"webp": tex_image.load_webp_from_buffer(image_buffer)
		"svg": tex_image.load_svg_from_buffer(image_buffer)
		_:
			_log.e("%s format not recognised." % file_type)
			return null
	
	if tex_image.is_empty():
		_log.w("Image %s is empty" % url)
		return null
	
	var tex := ImageTexture.create_from_image(tex_image)
	texture_cache[url] = tex
	return tex


func load_texture_from_data_folder(texture_file_name: String) -> Texture2D:
	if texture_cache.has(texture_file_name):
		return texture_cache[texture_file_name]
	var tex: Texture2D
	if ResourceLoader.exists(RSSettings.LOCAL_RES_FOLDER + texture_file_name):
		tex = ResourceLoader.load(RSSettings.LOCAL_RES_FOLDER + texture_file_name)
	else:
		var tex_path := RSSettings.get_obj_path() + texture_file_name
		var tex_image := Image.load_from_file(tex_path)
		tex = ImageTexture.create_from_image(tex_image)
	texture_cache[texture_file_name] = tex
	return tex


func load_profile_pic_from_url(url: String, use_cached := true) -> ImageTexture:
	# 1) Try disk cache
	var cache_path := _profile_pic_cache_path(url)
	if use_cached and FileAccess.file_exists(cache_path):
		var tex := _load_texture_from_disk(cache_path)
		if tex:
			if not texture_cache.has(url):
				texture_cache[url] = tex
			return tex
	# 2) Fetch via generic loader (RAM cache unaffected)
	var tex2 := await load_texture_from_url(url, use_cached)
	if tex2 == null:
		return null
	# 3) Save to disk cache (keeps extension from URL)
	_profile_pic_cache_store_original(cache_path, tex2)
	return tex2


#region Helpers
func _profile_pic_cache_path(url: String) -> String:
	var ext := url.get_extension().to_lower()
	if not _IMG_SUPPORTED_EXT.has(ext):
		ext = "png"  # safe fallback if URL has no/odd extension
	var fname := "%s.%s" % [url.md5_text(), ext]
	return _profile_pic_cache_dir.path_join(fname)


func _profile_pic_cache_store_original(path: String, tex: Texture2D) -> void:
	var dir := path.get_base_dir()
	DirAccess.make_dir_recursive_absolute(dir)
	var img := tex.get_image()
	if img == null or img.is_empty():
		return
	# Save using the extension implied by path
	match path.get_extension().to_lower():
		"png":
			if img.save_png(path + ".tmp") == OK:
				_finalize_tmp(path)
		"jpg", "jpeg":
			var tmp := path + ".tmp"
			# 0..100; pick 90 as a reasonable default
			if img.save_jpg(tmp, 90) == OK:
				_finalize_tmp(path)
		"webp":
			var tmpw := path + ".tmp"
			# lossless=false, quality 0..100
			if img.save_webp(tmpw, false, 90) == OK:
				_finalize_tmp(path)
		"bmp":
			var tmpb := path + ".tmp"
			if img.save_bmp(tmpb) == OK:
				_finalize_tmp(path)
		"svg":
			# We decoded from a raster buffer; saving back to SVG isn't supported.
			# Fallback to PNG next to the intended path.
			var fallback := path.get_basename() + ".png"
			var tmp := fallback + ".tmp"
			if img.save_png(tmp) == OK:
				_finalize_tmp(fallback)
		_:
			var tmpd := path + ".tmp"
			if img.save_png(tmpd) == OK:
				_finalize_tmp(path)


func _finalize_tmp(final_path: String) -> void:
	var tmp := final_path + ".tmp"
	if FileAccess.file_exists(final_path):
		DirAccess.remove_absolute(final_path)
	DirAccess.rename_absolute(tmp, final_path)


func _load_texture_from_disk(path: String) -> ImageTexture:
	var img := Image.load_from_file(path)
	if img.is_empty():
		return null
	return ImageTexture.create_from_image(img)
#endregion
