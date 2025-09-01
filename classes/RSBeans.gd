extends Resource
class_name RSBeans


@export var name: String = ""
@export var filename: String = ""
@export var scale_modifier: float = 1.0
@export var scale_randomness: float = 0.0
@export var definitions: Array[RSBeanDefinition] = []
@export var spawn_count_min: int = 1
@export var spawn_count_max: int = 3
@export var layer: int = 1 # min 1 max 10
@export var on_destroy_shards: RSBeans

@warning_ignore_start("unused_private_class_variable")
var _coll_layer: int: # 0b100
	get: return 0b0001 << layer
var _coll_mask: int: # 0b101
	get: return 0b0001 + _coll_layer
@warning_ignore_restore("unused_private_class_variable")


func to_dict() -> Dictionary:
	var d = {}
	d["name"] = name # String
	d["filename"] = filename # String
	d["scale_modifier"] = scale_modifier # float
	d["scale_randomness"] = scale_randomness # float
	d["definitions"] = [] # Array[RSBeanDefinition]
	for def: RSBeanDefinition in definitions:
		d["definitions"].append(def.to_dict())
	d["spawn_count_min"] = spawn_count_min # int
	d["spawn_count_max"] = spawn_count_max # int
	d["layer"] = layer # int
	d["on_destroy_shards"] = on_destroy_shards.to_dict() # RSBeans
	return d


static func from_json(d: Dictionary) -> RSBeans:
	var new_beans: RSBeans = RSBeans.new()
	new_beans.name = d.get("name", "")
	new_beans.filename = d.get("filename", "")
	new_beans.scale_modifier = d.get("scale_modifier", 1.0)
	new_beans.scale_randomness = d.get("scale_randomness", 0.0)
	new_beans.definitions = []
	for dict: Dictionary in d.get("definitions", []):
		new_beans.definitions.append(RSBeanDefinition.from_json(dict))
	new_beans.spawn_count_min = d.get("spawn_count_min", 1)
	new_beans.spawn_count_max = d.get("spawn_count_max", 3)
	new_beans.layer = d.get("layer", 1)
	if d.has("on_destroy_shards") and d.get("on_destroy_shards", {}) != {}:
		new_beans.on_destroy_shards = RSBeans.from_json( d.get("on_destroy_shards", {}) )
	return new_beans
