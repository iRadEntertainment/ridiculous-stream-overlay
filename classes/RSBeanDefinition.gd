extends Resource
class_name RSBeanDefinition

# external wrap class
#var spawn_count_min: int = 1
#var spawn_count_max: int = 1
#var coll_layer: int = 0b100
#var coll_mask: int = 0b101
#var destroy_shard_params: RSBeansParam


var img_path: String
var scale: float = 1.0
var sfx_paths: Array = []
var sfx_volume: int = 0
var is_destroy: bool = true
var is_pickable: bool = true
var is_poly_fracture: bool = false


func to_dict() -> Dictionary:
	var d = {}
	d["img_path"] = img_path
	d["scale"] = scale
	d["sfx_paths"] = sfx_paths
	d["sfx_volume"] = sfx_volume
	d["is_destroy"] = is_destroy
	d["is_pickable"] = is_pickable
	d["is_poly_fracture"] = is_poly_fracture
	return d


func to_json() -> String:
	return JSON.stringify(to_dict())


static func from_json(d: Dictionary) -> RSBeanDefinition:
	var param := RSBeanDefinition.new()
	param.img_path = d.get("img_path", "")
	param.scale = d.get("scale", 1.0)
	param.sfx_paths = d.get("sfx_paths", [])
	param.sfx_volume = d.get("sfx_volume", 0)
	param.is_destroy = d.get("is_destroy", false)
	param.is_pickable = d.get("is_pickable", false)
	param.is_poly_fracture = d.get("is_poly_fracture", false)
	return param
