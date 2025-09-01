# Utilities
class_name RSUtl

const TYPE_NAMES := {
	TYPE_BOOL: "bool",
	TYPE_INT: "int",
	TYPE_FLOAT: "float",
	TYPE_STRING: "String",
	TYPE_VECTOR2: "Vector2",
	TYPE_VECTOR2I: "Vector2i",
	TYPE_RECT2: "Rect2",
	TYPE_RECT2I: "Rect2i",
	TYPE_VECTOR3: "Vector3",
	TYPE_VECTOR3I: "Vector3i",
	TYPE_TRANSFORM2D: "Transform2D",
	TYPE_VECTOR4: "Vector4",
	TYPE_VECTOR4I: "Vector4i",
	TYPE_PLANE: "Plane",
	TYPE_QUATERNION: "Quaternion",
	TYPE_AABB: "AABB",
	TYPE_BASIS: "Basis",
	TYPE_TRANSFORM3D: "Transform3D",
	TYPE_PROJECTION: "Projection",
	TYPE_COLOR: "Color",
	TYPE_STRING_NAME: "StringName",
	TYPE_NODE_PATH: "NodePath",
	TYPE_RID: "Rid",
	TYPE_OBJECT: "Object",
	TYPE_CALLABLE: "Callable",
	TYPE_SIGNAL: "Signal",
	TYPE_DICTIONARY: "Dictionary",
	TYPE_ARRAY: "Array",
	TYPE_PACKED_BYTE_ARRAY: "PackedByteArray",
	TYPE_PACKED_INT32_ARRAY: "PackedInt32Array",
	TYPE_PACKED_INT64_ARRAY: "PackedInt64Array",
	TYPE_PACKED_FLOAT32_ARRAY: "PackedFloat32Array",
	TYPE_PACKED_FLOAT64_ARRAY: "PackedFloat64Array",
	TYPE_PACKED_STRING_ARRAY: "PackedStringArray",
	TYPE_PACKED_VECTOR2_ARRAY: "PackedVector2Array",
	TYPE_PACKED_VECTOR3_ARRAY: "PackedVector3Array",
	TYPE_PACKED_COLOR_ARRAY: "PackedColorArray",
	TYPE_PACKED_VECTOR4_ARRAY: "PackedVector4Array",
}

static var _log: TwitchLogger = TwitchLogger.new(&"RSUtl")

static func _static_init() -> void:
	_log.enabled = true


static func save_to_json(file_path: String, variant: Variant) -> void:
	var file := FileAccess.open(file_path, FileAccess.WRITE)
	if file == null:
		_log.e("Save_to_json: Failed to open %s" % [file_path])
		return
	file.store_string(JSON.stringify(variant, "\t"))
	file.close()


static func load_json(file_path: String) -> Variant:
	var file := FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		_log.e("Load_json: Failed to open %s" % [file_path])
		return null
	var content := file.get_as_text()
	var parsed = JSON.parse_string(content)
	if parsed == null:
		_log.e("Load_json: Failed to parse JSON in %s" % [file_path])
		return null
	return parsed


static func get_type_string(p_value: Variant) -> String:
	var type_of_value := typeof(p_value)
	if type_of_value == TYPE_NIL:
		return &"null"
	if type_of_value >= TYPE_MAX:
		return "Invalid/unknown type %d" % type_of_value
	var type_name = TYPE_NAMES.get(type_of_value)
	if type_of_value != TYPE_OBJECT:
		if type_name == null:
			return "Invalid/unknown type %d" % type_of_value
		else:
			return type_name
	var value_object := p_value as Object
	var value_class := value_object.get_class()
	if value_class == null:
		return "%s (unknown)" % [type_name]
	@warning_ignore("incompatible_ternary")
	return "%s (%s)" % [
		type_name,
		&"unknown" if value_class == null else value_class
	]


static func make_path(path) -> void:
	if !DirAccess.dir_exists_absolute(path):
		DirAccess.make_dir_recursive_absolute(path)


static func fix_external_res(file_path: String, from: String, to: String):
	if !FileAccess.file_exists(file_path):
		_log.e("%s is not a valid file_path"%file_path)
		return
	var file := FileAccess.open(file_path, FileAccess.READ_WRITE)
	file.store_string(file.get_as_text().replace(from, to))
	file.close()


static func list_file_in_folder(folder_path: String, types: Array = [], full_path := false) -> PackedStringArray:
	var found_files: PackedStringArray = []

	if !folder_path.ends_with("/"):
		folder_path += "/"

	if !DirAccess.dir_exists_absolute(folder_path):
		DirAccess.make_dir_recursive_absolute(folder_path)

	var dir := DirAccess.open(folder_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if !dir.current_is_dir():
				if file_name.get_extension() in types or types.is_empty():
					if not full_path:
						found_files.append(file_name)
					else:
						found_files.append(folder_path + file_name)
					_log.d("Found file: " + file_name)
			file_name = dir.get_next()
	else:
		_log.e("An error occurred when trying to access the directory: %s" % folder_path)
	return found_files


static func get_file_creation_unix(abs_path: String) -> float:
	abs_path = abs_path.replace("/", "\\")
	var args := [
		"-NoProfile",
		"-Command",
		"(Get-Date (Get-Item '%s').CreationTime -UFormat '%%s')" % abs_path
	]
	
	var output := []
	var exit_code := OS.execute("powershell", args, output, true)
	
	if exit_code == 0 and output.size() > 0:
		var creation_date_str: String = output[0].strip_edges()
		return float(creation_date_str)
	
	_log.e("Failed to get creation date for: %s" % abs_path)
	return -1.0



static func fit_and_center_window_to_display(p_window: Window) -> void:
	var current_screen := p_window.current_screen
	var current_screen_usable_rect := DisplayServer.screen_get_usable_rect(current_screen)
	var window_size := p_window.size
	var decorated_size := p_window.get_size_with_decorations()
	var decorations_size := decorated_size - window_size
	var target_size_x := mini(current_screen_usable_rect.size.x, decorated_size.x) - decorations_size.x
	var target_size_y := mini(current_screen_usable_rect.size.y, decorated_size.y) - decorations_size.y
	var target_size := Vector2i(mini(target_size_x, window_size.x), mini(target_size_y, window_size.y))
	p_window.size = target_size
	p_window.position = Vector2(current_screen_usable_rect.position) - (target_size - p_window.get_size_with_decorations()) / 2.0


static func resize_img_to_max_dim(img: Image, max_dim: int) -> Image:
	var width: int
	var height: int
	var _is_taller: bool = img.get_size().x < img.get_size().y
	if _is_taller:
		@warning_ignore("integer_division")
		width = (max_dim * img.get_size().x) / img.get_size().y
		height = max_dim
	else:
		width = max_dim
		@warning_ignore("integer_division")
		height = (max_dim * img.get_size().y) / img.get_size().x
	var resized_image: Image = img.duplicate()
	resized_image.resize(width, height)
	return resized_image


static func opt_btn_from_files_in_folder(folder_paths: Array[String], types: Array[String] = [], full_path := false) -> OptionButton:
	var new_opt_btn := OptionButton.new()
	populate_opt_btn_from_files_in_folder(new_opt_btn, folder_paths, types, full_path)
	return new_opt_btn


static func populate_opt_btn_from_files_in_folder(opt_btn: OptionButton, folder_paths: Array[String], types: Array[String] = [], full_path := false):
	opt_btn.clear()
	opt_btn.add_item("", 0)
	opt_btn.add_separator("External Resources")
	for i in folder_paths.size():
		var folder = folder_paths[i]
		var list_of_files = RSUtl.list_file_in_folder(folder, types, full_path)
		for file in list_of_files:
			opt_btn.add_item(file, opt_btn.item_count+1)
		if i < folder_paths.size()-1:
			opt_btn.add_separator("Local Resources")


static func opt_btn_populate_from_list(opt_button: OptionButton, list: Array[String], add_empty := true):
	opt_button.clear()
	if add_empty:
		opt_button.add_item("", 0)
	for i in list.size():
		var file_name = list[i]
		opt_button.add_item(file_name, i+1)


static func get_methods_from_script(
			script_filepath: String,
			exclude: Array[String] = [],
			exclude_begin_with: String = "",
		) -> Array[String]:
	
	var custom_script: GDScript = ResourceLoader.load(
		script_filepath,
		"GDScript",
		ResourceLoader.CACHE_MODE_IGNORE
	)
	var functions_dics: Array[Dictionary] = custom_script.get_script_method_list()
	var functions: Array[String] = []
	for f_dic: Dictionary in functions_dics:
		if f_dic.name in exclude: continue
		if exclude_begin_with != "":
			if f_dic.name.begins_with(exclude_begin_with): continue
		functions.append(f_dic.name)
	return functions


static func rename_file(from_abs: String, to_abs: String) -> void:
	DirAccess.rename_absolute(from_abs, to_abs)


static func get_newest_file(file_absolute_paths: Array) -> String:
	var newest_file = ""
	var latest_time = 0
	for path in file_absolute_paths:
		var modified_time = FileAccess.get_modified_time(path)
		if modified_time > latest_time:
			latest_time = modified_time
			newest_file = path
	return newest_file


static func opt_btn_select_from_text(opt_button: OptionButton, text: String) -> void:
	for i in opt_button.item_count:
		if opt_button.get_item_text(i) == text:
			opt_button.select(i)
			break


static func convert_html_to_bbcode(html: String) -> String:
	# 1. Unescape HTML entities
	var bb = html_unescape(html)

	# 2. Replace <img ... src="..."> with [img]...[/img]
	var img_re = RegEx.create_from_string(r'<img[^>]*src=["\']([^"\']+)["\'][^>]*/?>')
	bb = img_re.sub(bb, "[img]$1[/img]", true)

	# 3. Replace <h2 ...>...</h2> with [b]...[/b]
	var h2_open_re = RegEx.create_from_string(r'<h2[^>]*>')
	bb = h2_open_re.sub(bb, "[b]", true)
	bb = bb.replace("</h2>", "[/b]\n")

	# 4. Remove <p> tags, convert </p> to newline
	var p_open_re = RegEx.create_from_string(r'<p[^>]*>')
	bb = p_open_re.sub(bb, "", true)
	bb = bb.replace("</p>", "\n")

	# 5. List items: <li> → •, </li> → newline
	bb = bb.replace("<li>", "• ")
	bb = bb.replace("</li>", "\n")
	# Remove <ul> and </ul>
	var ul_re = RegEx.create_from_string(r'</?ul[^>]*>')
	bb = ul_re.sub(bb, "", true)

	# 6. Remove <div ...> and </div>
	var div_re = RegEx.create_from_string(r'</?div[^>]*>')
	bb = div_re.sub(bb, "", true)

	# 7. Strip any remaining tags
	var any_tag_re = RegEx.create_from_string(r'<[^>]+>')
	bb = any_tag_re.sub(bb, "", true)

	# 8. Trim and normalize spacing
	bb = bb.strip_edges()
	bb = bb.replace("\n\n\n", "\n\n")

	return bb


static func html_unescape(text: String) -> String:
	var replacements = {
		"&lt;": "<",
		"&gt;": ">",
		"&amp;": "&",
		"&quot;": "\"",
		"&#39;": "'",
		"&#x27;": "'",
		"&#x2F;": "/",
		"&#96;": "`",
		"&nbsp;": " ",
		"&copy;": "©",
		"&reg;": "®",
		"&euro;": "€",
		"&pound;": "£",
		"&yen;": "¥",
		"&ndash;": "–",
		"&mdash;": "—",
		"&lsquo;": "‘",
		"&rsquo;": "’",
		"&ldquo;": "“",
		"&rdquo;": "”",
		"&hellip;": "…",
		"&bull;": "•"
	}

	for key in replacements.keys():
		text = text.replace(key, replacements[key])
	return text


static func validate_handle(handle_text: String) -> String:
	handle_text = handle_text.strip_edges()
	handle_text = handle_text.replace("@", "")
	if handle_text.is_empty():
		return ""
	return "@" + handle_text


#region Time Parsers
const WEEKDAYS = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
const MONTHS_SHORT = ["Jan", "Feb", "Mar", "Apr", "Maj", "Jun", "Jul", "Aug", "Set", "Oct", "Nov", "Dec"]
const FORMAT_STRING_TIME = "%d:%02d:%02d"
const FORMAT_STRING_DATE = "{day} {month} {year}"
const FORMAT_STRING_DATE_FILE = "{year}_{month}_{day}"
const FORMAT_STRING_TIME_FILE = "%d_%02d_%02d"


static func get_unix_time_utc_from_system() -> int:
	var dict = Time.get_datetime_dict_from_system()
	return Time.get_unix_time_from_datetime_dict(dict)


static func unix_to_string(
			unix: float,
			include_weekday := true,
			include_time := true,
			dz_enabled := true) -> String:
	if !unix: return "Never"
	if dz_enabled:
		var tz_offset_usec = Time.get_time_zone_from_system().bias * 60
		unix += tz_offset_usec
	var dict: Dictionary = Time.get_datetime_dict_from_unix_time(int(unix))
	dict.weekday = WEEKDAYS[dict.weekday]
	dict.month = MONTHS_SHORT[dict.month-1]
	
	var format_string: String = FORMAT_STRING_DATE
	if include_weekday:
		format_string = "{weekday} " + format_string
	if include_time:
		var time_string: String = (FORMAT_STRING_TIME % [dict.hour, dict.minute, dict.second])
		format_string = format_string + " - " + time_string
	return format_string.format(dict)


static func unix_to_string_filepath(unix: float, include_time := false) -> String:
	if !unix: return "Never"
	
	var tz_offset_usec = Time.get_time_zone_from_system().bias * 60
	unix += tz_offset_usec
	var dict: Dictionary = Time.get_datetime_dict_from_unix_time(int(unix))
	dict.weekday = WEEKDAYS[dict.weekday]
	dict.month = MONTHS_SHORT[dict.month-1]
	
	var format_string: String = FORMAT_STRING_DATE_FILE.format(dict)
	
	if include_time:
		var time_string: String = (FORMAT_STRING_TIME_FILE % [dict.hour, dict.minute, dict.second])
		format_string += "_" + time_string
	
	return format_string
#endregion
