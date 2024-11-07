extends RefCounted
class_name RSGlobals


const pnl_settings_pack = preload ("res://instances/pnl_settings.tscn")
const param_inspector_pack = preload ("res://instances/param_inspector.tscn")

const msg_notif_pack = preload ("res://instances/msg_notification.tscn")
const btn_user_pack = preload ("res://instances/btn_user.tscn")
const notif_vetting_reward_pack = preload ("res://instances/notification_vetting_reward.tscn")

const lb_body_pack = preload ("res://instances/lb_rigidbody.tscn")
const laser_scene_pack = preload ("res://instances/laser_emitter.tscn")
const granade_pack = preload ("res://instances/granade.tscn")

const DEFAULT_RIGID_LABEL_COLOR = "#29c3a6"

const PARAMS_CANS = {
		"img_paths": ["can.png"],
		"sfx_paths": ["sfx_can_01.ogg", "sfx_can_02.ogg", "sfx_can_03.ogg", "sfx_can_04.ogg"],
		"sfx_volume": - 12.0,
		"spawn_count_min": 3,
		"spawn_count_max": 5,
		"is_pickable": true,
		"is_poly_fracture": false,
		"is_destroy": true,
		"scale": 0.3,
		"coll_layer": 4,
		"coll_mask": 5,
		"destroy_shard_params": PARAM_BEANS
	}
const PARAM_BEANS = {
		"img_paths": ["bean_01.png", "bean_02.png"],
		"sfx_paths": [],
		"sfx_volume": 0.0,
		"spawn_count_min": 7,
		"spawn_count_max": 14,
		"is_pickable": false,
		"is_poly_fracture": false,
		"is_destroy": false,
		"scale": 0.5,
		"coll_layer": 2,
		"coll_mask": 3,
	}
