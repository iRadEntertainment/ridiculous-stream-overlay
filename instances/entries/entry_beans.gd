extends PanelContainer
class_name EntryBeans

var beans: RSBeans
var is_editable: bool = true

signal delete_pressed(entry: EntryBeans)


func _ready() -> void:
	update_opt_btns()
	_populate()


func _populate() -> void:
	if not beans:
		clear()
	%lb_name.text = beans.name
	%lb_filename.text = beans.filename
	%sl_scale_modifier.value = beans.scale_modifier
	%sl_scale_randomness.value = beans.scale_randomness
	for child in %flow_definitions.get_children():
		child.free()
	for def: RSBeanDefinition in beans.definitions:
		var entry: HBoxContainer = entry_from_definition(def)
		%flow_definitions.add_child(entry)
	%sp_spawn_count_min.value = beans.spawn_count_min # int = 1
	%sp_spawn_count_max.value = beans.spawn_count_max # int = 3
	%sp_layer.value = beans.layer # int = 1 # min 1 max 10
	%opt_on_destroy_shards.select = beans.on_destroy_shards # RSBeans


func update_opt_btns() -> void:
	var _beans_filepaths = RSUtl.list_file_in_folder(RSSettings.get_obj_path(), ["json"], true)
	%opt_on_destroy_shards.clear()
	for i: int in _beans_filepaths.size():
		var filepath: String = _beans_filepaths[i]
		var filename: String = filepath.get_file()
		var d: Dictionary = RSUtl.load_json(filepath)
		if d.has(""):
			continue
		var beans: RSBeans = RSBeans.from_json(d)
		
		%opt_on_destroy_shards.add_item(filename, i)
	%opt_on_destroy_shards.select(-1)


func clear() -> void:
	%lb_name.text = ""
	%lb_filename.text = ""
	%sl_scale_modifier.value = 1.0
	%sl_scale_randomness.value = 0.0
	for child in %flow_definitions.get_children():
		child.free()
	%sp_spawn_count_min.value = 1
	%sp_spawn_count_max.value = 3
	%sp_layer.value = 1
	%opt_on_destroy_shards.select(-1)


func entry_from_definition(def: RSBeanDefinition) -> HBoxContainer:
	var hb := HBoxContainer.new()
	
	var tex_rect := TextureRect.new()
	tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tex_rect.custom_minimum_size = Vector2.ONE * 24
	tex_rect.texture = RS.loader.load_texture_from_data_folder(def.img_path)
	hb.add_child(tex_rect)
	
	var lb := Label.new()
	lb.text = def.name
	lb.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	lb.custom_minimum_size.x = 80
	hb.add_child(lb)
	
	if is_editable:
		var btn := Button.new()
		btn.icon = preload("res://ui/icons/bootstrap_icons/x.svg")
		btn.expand_icon = true
		btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		btn.custom_minimum_size = Vector2.ONE * 24
		btn.pressed.connect(_on_definition_entry_delete_pressed.bind(hb, def))
		hb.add_child(btn)
	return hb


func _on_definition_entry_delete_pressed(entry: HBoxContainer, def: RSBeanDefinition) -> void:
	if beans.definitions.size() < 2: return
	beans.definitions.erase(def)
	entry.queue_free()


func _on_btn_delete_pressed() -> void:
	delete_pressed.emit(self)
