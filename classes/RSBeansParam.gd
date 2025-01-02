
extends Resource
class_name RSBeansParam


var img_paths: Array = []
var sfx_paths: Array = []
var spawn_count_min: int = 1
var spawn_count_max: int = 1
var coll_layer: int = 0b100
var coll_mask: int = 0b101
var sfx_volume: int = 0
var is_destroy: bool = true
var is_pickable: bool = true
var is_poly_fracture: bool = false
var scale: float = 1.0
var destroy_shard_params: RSBeansParam


func to_dict() -> Dictionary:
	var d = {}
	d["img_paths"] = img_paths
	d["sfx_paths"] = sfx_paths
	d["spawn_count_min"] = spawn_count_min
	d["spawn_count_max"] = spawn_count_max
	d["coll_layer"] = coll_layer
	d["coll_mask"] = coll_mask
	d["sfx_volume"] = sfx_volume
	d["is_destroy"] = is_destroy
	d["is_pickable"] = is_pickable
	d["is_poly_fracture"] = is_poly_fracture
	d["scale"] = scale
	if destroy_shard_params:
		d["destroy_shard_params"] = destroy_shard_params.to_dict()
	else:
		d["destroy_shard_params"] = null
	return d


func to_json() -> String:
	return JSON.stringify(to_dict())

static func from_json(d: Dictionary) -> RSBeansParam:
	var param := RSBeansParam.new()
	param.img_paths = d.get("img_paths", [])
	param.sfx_paths = d.get("sfx_paths", [])
	param.spawn_count_min = d.get("spawn_count_min", 1)
	param.spawn_count_max = d.get("spawn_count_max", 1)
	param.coll_layer = d.get("coll_layer", 1)
	param.coll_mask = d.get("coll_mask", 1)
	param.sfx_volume = d.get("sfx_volume", 0)
	param.is_destroy = d.get("is_destroy", false)
	param.is_pickable = d.get("is_pickable", false)
	param.is_poly_fracture = d.get("is_poly_fracture", false)
	# TODO: remove user _scale fix
	var _scale = d.get("scale", 1.0)
	if _scale is Array:
		_scale = float(_scale.front())
	param.scale = _scale
	if d.has("destroy_shard_params"):
		if d.destroy_shard_params is Dictionary:
			param.destroy_shard_params = RSBeansParam.from_json(d["destroy_shard_params"])
	return param
