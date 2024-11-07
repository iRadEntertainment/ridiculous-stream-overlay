# Utilities
class_name RSUtl


static func save_to_json(file_path: String, variant: Variant) -> void:
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(variant, "\t"))
	file.close()
static func load_json(file_path: String) -> Variant:
	var file = FileAccess.open(file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	return JSON.parse_string(content)


static func make_path(path):
	if !DirAccess.dir_exists_absolute(path):
		DirAccess.make_dir_recursive_absolute(path)


static func fix_external_res(file_path : String, from : String, to : String):
	if !FileAccess.file_exists(file_path):
		push_error("%s is not a valid file_path"%file_path)
		return
	var file := FileAccess.open(file_path, FileAccess.READ_WRITE)
	file.store_string(file.get_as_text().replace(from, to))
	file.close()


static func list_file_in_folder(folder_path : String, types : Array = [], full_path := false) -> PackedStringArray:
	var found_files : PackedStringArray = []
	
	if !folder_path.ends_with("/"):
		folder_path += "/"
	var dir = DirAccess.open(folder_path)
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
					#print("Found file: " + file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	
	return found_files


static func opt_btn_from_files_in_folder(folder_paths : Array[String], types : Array[String] = [], full_path := false) -> OptionButton:
	var new_opt_btn := OptionButton.new()
	populate_opt_btn_from_files_in_folder(new_opt_btn, folder_paths, types, full_path)
	return new_opt_btn


static func populate_opt_btn_from_files_in_folder(opt_btn : OptionButton, folder_paths : Array[String], types : Array[String] = [], full_path := false):
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
