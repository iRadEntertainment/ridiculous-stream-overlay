extends PanelContainer
class_name PnlBeansEditor


const IMG_EXT = ["jpg", "png", "jpeg", "svg", "webp"]
const SFX_EXT = ["ogg", "waw", "mp3"]

var _bean_definitions: Array[RSBeanDefinition]
var _beans_filepaths: PackedStringArray
var _img_filenames_local: PackedStringArray
var _img_filenames_external: PackedStringArray
var _sfx_filenames_local: PackedStringArray
var _sfx_filenames_external: PackedStringArray

var _current: RSBeanDefinition:
	set(val):
		_current = val
		clear()
		if !is_node_ready(): await ready
		%btn_save_definition.disabled = _current == null
		%pnl_block.visible = _current == null


#region Init/Populate
func _ready() -> void:
	%pnl_block.show()
	%preview.draw.connect(_draw_preview)
	clear()


func start() -> void:
	load_data_from_disk()
	_populate_beans_json_list()
	_populate_images_list()


func load_data_from_disk() -> void:
	_bean_definitions.clear()
	
	_beans_filepaths = RSUtl.list_file_in_folder(RSSettings.get_obj_path(), ["json"], true)
	_img_filenames_local = RSUtl.list_file_in_folder("res://local_res/", IMG_EXT)
	_img_filenames_external = RSUtl.list_file_in_folder(RSSettings.get_obj_path(), IMG_EXT)
	_sfx_filenames_local = RSUtl.list_file_in_folder("res://local_res/", SFX_EXT)
	_sfx_filenames_external = RSUtl.list_file_in_folder(RSSettings.get_sfx_path(), SFX_EXT)


func _populate_beans_json_list() -> void:
	%opt_load_bean_definition.clear()
	for i: int in _beans_filepaths.size():
		var filepath: String = _beans_filepaths[i]
		var d: Dictionary = RSUtl.load_json(filepath)
		var def: RSBeanDefinition = RSBeanDefinition.from_json(d)
		_bean_definitions.append(def)
		
		var filename: String = filepath.get_file()
		%opt_load_bean_definition.add_item(filename, i)
	%opt_load_bean_definition.select(-1)


func _populate_images_list() -> void:
	%opt_img_path.clear()
	%opt_img_path.add_separator("Local")
	for filename: String in _img_filenames_local:
		var img: Image = RS.loader.load_texture_from_data_folder(filename).get_image()
		var img_resized: Image = RSUtl.resize_img_to_max_dim(img, 24)
		var item_tex: Texture2D = ImageTexture.create_from_image(img_resized)
		%opt_img_path.add_icon_item(item_tex, filename)
	%opt_img_path.add_separator("External")
	for filename: String in _img_filenames_external:
		var img: Image = RS.loader.load_texture_from_data_folder(filename).get_image()
		var img_resized: Image = RSUtl.resize_img_to_max_dim(img, 24)
		var item_tex: Texture2D = ImageTexture.create_from_image(img_resized)
		%opt_img_path.add_icon_item(item_tex, filename)
	%opt_img_path.select(-1)


func clear() -> void:
	%ln_name.text = ""
	%opt_img_path.select(-1)
	%sl_scale.value = 1.0
	%sl_coll_offset.value = 0.0
	%sl_pick_offset.value = 0.0
	# sfx
	for child in %vb_sfx_list.get_children():
		child.queue_free()
	%ck_is_destroy.button_pressed = true
	%ck_is_pickable.button_pressed = true
	%ck_is_poly_fracture.button_pressed = false
#endregion


#region Display
func _populate_bean_param(def: RSBeanDefinition) -> void:
	%ln_name.text = def.name
	RSUtl.opt_btn_select_from_text(%opt_img_path, def.img_path)
	%sl_scale.value = def.scale
	%lb_scale.text = "%0.2f" % def.scale
	%sl_coll_offset.value = def.collision_offset
	%lb_coll_offset.text = "%0.2f" % def.collision_offset
	%sl_pick_offset.value = def.pick_offset
	%lb_pick_offset.text = "%0.2f" % def.pick_offset
	
	for sfx_path: String in def.sfx_dict:
		_add_sfx_entry(sfx_path, def.sfx_dict[sfx_path])
	%ck_is_destroy.button_pressed = def.is_destroy
	%ck_is_pickable.button_pressed = def.is_pickable
	%ck_is_poly_fracture.button_pressed = def.is_poly_fracture


func _draw_preview() -> void:
	if not _current: return
	if not _current.img_path:
		return
	var tex: Texture2D = RS.loader.load_texture_from_data_folder(_current.img_path)
	var tex_rect: Rect2 = Rect2()
	tex_rect.size = tex.get_size() * _current.scale
	tex_rect.position = %preview.size/2.0 - tex_rect.size/2.0
	
	# corners
	var p0: Vector2 = tex_rect.position
	var p1: Vector2 = Vector2(tex_rect.end.x, tex_rect.position.y)
	var p2: Vector2 = tex_rect.end
	var p3: Vector2 = Vector2(tex_rect.position.x, tex_rect.end.y)
	_draw_corners(p0, [Vector2.UP, Vector2.LEFT], 16.0, 1.0, 4.0, Color.GREEN)
	_draw_corners(p1, [Vector2.UP, Vector2.RIGHT], 16.0, 1.0, 4.0, Color.GREEN)
	_draw_corners(p2, [Vector2.DOWN, Vector2.RIGHT], 16.0, 1.0, 4.0, Color.GREEN)
	_draw_corners(p3, [Vector2.DOWN, Vector2.LEFT], 16.0, 1.0, 4.0, Color.GREEN)
	
	# pick area (sprite texture in between)
	if _current.is_pickable:
		var pick_rect: Rect2 = tex_rect
		var pick_px_offset: float = min(tex_rect.size.x, tex_rect.size.y) * _current.pick_offset / 2.0
		pick_rect.position += Vector2.ONE * pick_px_offset
		pick_rect.size -= Vector2.ONE * pick_px_offset * 2.0
		%preview.draw_rect(pick_rect, Color.ORANGE - Color(0,0,0,0.8))
		# sprite
		%preview.draw_texture_rect(tex, tex_rect, false)
		%preview.draw_rect(pick_rect, Color.ORANGE, false, 1.0, true)
	else:
		# sprite
		%preview.draw_texture_rect(tex, tex_rect, false)
	
	# collision area
	var coll_rect: Rect2 = tex_rect
	var coll_px_offset: float = min(tex_rect.size.x, tex_rect.size.y) * _current.collision_offset / 2.0
	coll_rect.position += Vector2.ONE * coll_px_offset
	coll_rect.size -= Vector2.ONE * coll_px_offset * 2.0
	_draw_capsule_from_rect(coll_rect)


func _draw_corners(
			p: Vector2,
			dirs: Array[Vector2] = [Vector2.UP, Vector2.LEFT],
			length: float = 16.0,
			width: float = 1.0,
			offset: float = 4.0,
			col: Color = Color.GREEN,
			antialiased: bool = true
		) -> void:
	for dir: Vector2 in dirs:
		%preview.draw_line(p + dir * offset, p + dir * length, col, width, antialiased)


func _draw_capsule_from_rect(
			rect: Rect2,
			col: Color = Color.LIGHT_BLUE,
			width: float = 1.0,
			antialiased: bool = true,
			_fill_alpha: float = 0.0
		) -> void:
	var is_horizontal: bool = rect.size.x > rect.size.y
	if is_horizontal:
		var radius: float = rect.size.y/2.0
		var p0: Vector2 = rect.position + Vector2.RIGHT * radius
		var p1: Vector2 = rect.position + Vector2.RIGHT * rect.size.x + Vector2.LEFT * radius
		var p2: Vector2 = rect.end + Vector2.LEFT * radius
		var p3: Vector2 = rect.end + Vector2.LEFT * rect.size.x + Vector2.RIGHT * radius
		var c0: Vector2 = Vector2(p0.x, p0.y + radius)
		var c1: Vector2 = Vector2(p1.x, p1.y + radius)
		%preview.draw_line(p0, p1, col, width, antialiased)
		%preview.draw_line(p2, p3, col, width, antialiased)
		%preview.draw_arc(c0, radius, PI*3.0/2.0, PI/2.0, 32, col, width, antialiased)
		%preview.draw_arc(c1, radius, PI/2.0, -PI/2.0, 32, col, width, antialiased)
	else:
		var radius: float = rect.size.x/2.0
		var p0: Vector2 = rect.position + Vector2.DOWN * radius
		var p1: Vector2 = rect.position + Vector2.DOWN * rect.size.y + Vector2.UP * radius
		var p2: Vector2 = rect.end + Vector2.UP * radius
		var p3: Vector2 = rect.end + Vector2.UP * rect.size.y + Vector2.DOWN * radius
		var c0: Vector2 = Vector2(p0.x + radius, p0.y)
		var c1: Vector2 = Vector2(p1.x + radius, p1.y)
		%preview.draw_line(p0, p1, col, width, antialiased)
		%preview.draw_line(p2, p3, col, width, antialiased)
		%preview.draw_arc(c0, radius, PI, TAU, 32, col, width, antialiased)
		%preview.draw_arc(c1, radius, 0, PI, 32, col, width, antialiased)
#endregion


#region Utilities
func _add_sfx_entry(sfx_filename: String = "", sfx_volume_linear: float = 1.0) -> void:
	var sfx_entry: EntrySfxBeans = preload("res://instances/entries/entry_sfx_beans.tscn").instantiate()
	sfx_entry.sfx_filename = sfx_filename
	sfx_entry.sfx_volume_linear = sfx_volume_linear
	sfx_entry.beans_editor = self
	%vb_sfx_list.add_child(sfx_entry)


func beans_name_to_json_filename(b_name: String) -> String:
	return "%s.json" % b_name.to_snake_case().validate_filename()


func save_bean_definition() -> void:
	if not _current: return
	if not _current.name: return
	# sfx
	_current.sfx_dict = {}
	for entry: EntrySfxBeans in %vb_sfx_list.get_children():
		var entry_dict: Dictionary[String, float] = entry.get_path_and_volume_dict()
		if entry_dict.is_empty():
			entry.queue_free()
		else:
			_current.sfx_dict.merge(entry_dict)
	
	var beans_filename: String = beans_name_to_json_filename(_current.name)
	var beans_path: String = RSSettings.get_obj_path().path_join(beans_filename)
	RSUtl.save_to_json(beans_path, _current.to_dict())
	load_data_from_disk()
	_populate_beans_json_list()
	RSUtl.opt_btn_select_from_text(%opt_load_bean_definition, beans_filename)
#endregion


#region Inspector Signals
func _on_btn_reload_opt_json_pressed() -> void:
	_bean_definitions.clear()
	_beans_filepaths = RSUtl.list_file_in_folder(RSSettings.get_obj_path(), ["json"], true)
	_populate_beans_json_list()
func _on_btn_reload_opt_img_pressed() -> void:
	_img_filenames_local = RSUtl.list_file_in_folder("res://local_res/", IMG_EXT)
	_img_filenames_external = RSUtl.list_file_in_folder(RSSettings.get_obj_path(), IMG_EXT)
	_populate_images_list()
func _on_btn_reload_opt_sfx_pressed() -> void:
	_sfx_filenames_local = RSUtl.list_file_in_folder("res://local_res/", SFX_EXT)
	_sfx_filenames_external = RSUtl.list_file_in_folder(RSSettings.get_sfx_path(), SFX_EXT)
	print("Not fully Implemented") # TODO: Update otion buttons for each SFX entry


func _on_btn_delete_json_pressed() -> void:
	var beans_filename: String = %opt_load_bean_definition.text
	var beans_path: String = RSSettings.get_obj_path().path_join(beans_filename)
	OS.move_to_trash(beans_path)
	_bean_definitions.clear()
	_beans_filepaths = RSUtl.list_file_in_folder(RSSettings.get_obj_path(), ["json"], true)
	_populate_beans_json_list()
	_current = null


func _on_btn_add_bean_definition_pressed() -> void:
	_current = RSBeanDefinition.new()
	%opt_load_bean_definition.select(-1)
	_populate_bean_param(_current)
func _on_opt_load_bean_definition_item_selected(index: int) -> void:
	_current = _bean_definitions[index]
	_populate_bean_param(_current)
func _on_btn_save_definition_pressed() -> void:
	save_bean_definition()


func _on_ln_name_text_changed(new_text: String) -> void:
	if _current: _current.name = new_text
func _on_opt_img_path_item_selected(_index: int) -> void:
	var is_same_name: bool = false
	if _current:
		is_same_name = _current.name == _current.img_path.get_basename()
		_current.img_path = %opt_img_path.text
	if is_same_name:
		%ln_name.text = %opt_img_path.text.get_basename()
		_current.name = %ln_name.text
	%preview.queue_redraw()


func _on_sl_scale_value_changed(value: float) -> void:
	%lb_scale.text = "%0.2f" % value
	if _current: _current.scale = value
	%preview.queue_redraw()
func _on_sl_coll_offset_value_changed(value: float) -> void:
	%lb_coll_offset.text = "%0.2f" % value
	if _current: _current.collision_offset = value
	%preview.queue_redraw()
func _on_sl_pick_offset_value_changed(value: float) -> void:
	%lb_pick_offset.text = "%0.2f" % value
	if _current: _current.pick_offset = value
	%preview.queue_redraw()


func _on_btn_add_sfx_pressed() -> void:
	_add_sfx_entry()


func _on_ck_is_destroy_toggled(toggled_on: bool) -> void:
	if _current: _current.is_destroy = toggled_on
	%preview.queue_redraw()
func _on_ck_is_pickable_toggled(toggled_on: bool) -> void:
	if _current: _current.is_pickable = toggled_on
	%preview.queue_redraw()
func _on_ck_is_poly_fracture_toggled(toggled_on: bool) -> void:
	if _current: _current.is_poly_fracture = toggled_on
	%preview.queue_redraw()
#endregion
