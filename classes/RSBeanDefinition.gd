extends Resource
class_name RSBeanDefinition

# external wrap class
#var spawn_count_min: int = 1
#var spawn_count_max: int = 1
#var coll_layer: int = 0b100
#var coll_mask: int = 0b101
#var destroy_shard_params: RSBeansParam


var name: String
var img_path: String
var scale: float = 1.0
var collision_offset: float = 0.0 # normalized
var pick_offset: float = 0.0 # normalized
var sfx_dict: Dictionary[String, float] = {} # {sfx_filename: volume_linear}
var is_destroy: bool = true
var is_pickable: bool = true
var is_poly_fracture: bool = false


func to_dict() -> Dictionary:
	var d = {}
	d["name"] = name
	d["img_path"] = img_path
	d["scale"] = scale
	d["collision_offset"] = collision_offset
	d["pick_offset"] = pick_offset
	d["sfx_dict"] = sfx_dict
	d["is_destroy"] = is_destroy
	d["is_pickable"] = is_pickable
	d["is_poly_fracture"] = is_poly_fracture
	return d


static func from_json(d: Dictionary) -> RSBeanDefinition:
	var param := RSBeanDefinition.new()
	param.name = d.get("name", "")
	param.img_path = d.get("img_path", "")
	param.scale = d.get("scale", 1.0)
	param.collision_offset = d.get("collision_offset", 0.0)
	param.pick_offset = d.get("pick_offset", 0.0)
	param.sfx_dict.assign(d.get("sfx_dict", {}))
	param.is_destroy = d.get("is_destroy", true)
	param.is_pickable = d.get("is_pickable", true)
	param.is_poly_fracture = d.get("is_poly_fracture", false)
	return param
