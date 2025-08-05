extends PanelContainer
class_name EntrySfxBeans

const TEX_VOLUME: Texture2D = preload("res://ui/icons/bootstrap_icons/volume-up-fill.svg")

var beans_editor: PnlBeansEditor
var sfx_filename: String = ""
var sfx_volume_linear: float = 1.0


func _ready() -> void:
	_populate_opt()
	
	if not sfx_filename.is_empty():
		RSUtl.opt_btn_select_from_text(%opt_sfx_path, sfx_filename)
	else:
		%opt_sfx_path.select(-1)
	%sl_volume.value = sfx_volume_linear
	%lb_volume.text = "%0.2f" % sfx_volume_linear


func _populate_opt() -> void:
	%opt_sfx_path.clear()
	if !beans_editor: return
	
	var img = RSUtl.resize_img_to_max_dim( TEX_VOLUME.get_image(), 24 )
	var resized_tex: Texture2D = ImageTexture.create_from_image(img)
	
	%opt_sfx_path.add_separator("Local")
	for filename: String in beans_editor._sfx_filenames_local:
		%opt_sfx_path.add_icon_item(resized_tex, filename)
	%opt_sfx_path.add_separator("External")
	for filename: String in beans_editor._sfx_filenames_external:
		%opt_sfx_path.add_icon_item(resized_tex, filename)


func get_path_and_volume_dict() -> Dictionary[String, float]:
	var d: Dictionary[String, float] = {}
	if sfx_filename:
		d[sfx_filename] = sfx_volume_linear
	return d


func _on_btn_preview_pressed() -> void:
	if %sfx_preview.playing:
		%sfx_preview.stop()
		return
	var sfx_filename: String = %opt_sfx_path.text
	%sfx_preview.stream = RS.loader.load_sfx_from_sfx_folder(sfx_filename)
	%sfx_preview.play()
func _on_sl_volume_value_changed(value: float) -> void:
	%lb_volume.text = "%0.2f" % value
	%sfx_preview.volume_linear = value
	sfx_volume_linear = value
func _on_btn_delete_sfx_pressed() -> void:
	queue_free()


func _on_opt_sfx_path_item_selected(_index: int) -> void:
	sfx_filename = %opt_sfx_path.text
