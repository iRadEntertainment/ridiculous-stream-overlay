@tool
extends EditorScript

func _run() -> void:
	var base_folder = ProjectSettings.globalize_path("res://ui/")
	var folder_src = "bootstrap_icons/"
	var list_svg = DirAccess.get_files_at(base_folder + folder_src)
	
	var png_size = 64
	var what = 'width="16" height="16" fill="currentColor"'
	var for_what = 'width="{size}" height="{size}" fill="{col}"'.format({"size": str(png_size), "col": "#ffffff"})
	var folder_dst = folder_src#"png_%s/"%png_size
	DirAccess.make_dir_recursive_absolute(base_folder + folder_dst)
	for i in list_svg.size():
		if list_svg[i].get_extension() != "svg": continue
		var filename_src = list_svg[i]
		var filename_dst = filename_src.trim_suffix("svg") + "png"
		var path_src = base_folder + folder_src + filename_src
		var path_dst = base_folder + folder_dst + filename_dst
		var f = FileAccess.open(path_src, FileAccess.READ)
		var file_content := f.get_as_text()
		f.close()
		file_content = file_content.replace(what, for_what)
		if i==0:
			print(file_content)
		var img = Image.create(png_size, png_size, true, Image.FORMAT_RGBAF)
		img.load_svg_from_string(file_content)
		img.save_png(path_dst)
	print("DONE")
	OS.shell_open(base_folder + folder_dst)
