@tool
extends TextureRect
class_name TextureRectLoad

@export var buffered_http_client: BufferedHTTPClient
@export var url: String
@export var use_own_client: bool:
	set(val):
		use_own_client = val
		if not is_node_ready(): await ready
		if val and not _own_client: _own_client = _create_client_node()
		if _own_client and not val: _own_client.queue_free()
@warning_ignore("unused_private_class_variable")
@export_tool_button("Reload url image") var _tool_btn_reload = load_from_url

var _own_client: HTTPRequest


func _enter_tree() -> void:
	if not buffered_http_client and BufferedHTTPClient.instance:
		if BufferedHTTPClient.instance.is_inside_tree():
			buffered_http_client = BufferedHTTPClient.instance


func _ready() -> void:
	%pnl_loading_simple.hide()


func load_from_url() -> void:
	if url.is_empty():
		texture = null
		return
	
	var file_type = url.get_extension()
	if not file_type in ["png", "jpeg", "jpg", "bmp", "webp", "svg"]:
		print("here")
		return
	
	%pnl_loading_simple.show()
	var tex_image: Image = Image.new()
	var img_buffer: PackedByteArray = PackedByteArray()
	
	if buffered_http_client and not use_own_client:
		var request: BufferedHTTPClient.RequestData = buffered_http_client.request(url, HTTPClient.METHOD_GET, {}, "")
		var response: BufferedHTTPClient.ResponseData = await buffered_http_client.wait_for_request(request)
		img_buffer = response.response_data
	
	elif use_own_client:
		if not _own_client:
			_own_client = _create_client_node()
		_own_client.request(url)
		var response: Array = await _own_client.request_completed
		img_buffer = response[3]
	else:
		return
	
	if !img_buffer.is_empty():
		match file_type:
			"png": tex_image.load_png_from_buffer(img_buffer)
			"jpeg", "jpg": tex_image.load_jpg_from_buffer(img_buffer)
			"bmp": tex_image.load_bmp_from_buffer(img_buffer)
			"webp": tex_image.load_webp_from_buffer(img_buffer)
			"svg": tex_image.load_svg_from_buffer(img_buffer)
	
	if !tex_image.is_empty():
		texture = ImageTexture.create_from_image(tex_image)
	
	%pnl_loading_simple.hide()


func _create_client_node() -> HTTPRequest:
	for child in get_children():
		if child is HTTPRequest:
			return child
	var _new_own_client = HTTPRequest.new()
	_new_own_client.name = "TextureHTTPRequest"
	add_child(_new_own_client)
	if Engine.is_editor_hint():
		_new_own_client.owner = self
	return _new_own_client


func _on_btn_reload_mouse_entered() -> void:
	if Engine.is_editor_hint(): return
	%reload_ico.show()

func _on_btn_reload_mouse_exited() -> void:
	if Engine.is_editor_hint(): return
	%reload_ico.hide()
