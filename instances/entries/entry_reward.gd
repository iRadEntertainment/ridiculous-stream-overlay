
extends PanelContainer

@onready var icon = %icon
@onready var title = %title
@onready var ck_is_active = %ck_is_active
@onready var ln_input = %ln_input
@onready var cost = %cost

var reward: TwitchCustomReward
var icon_img: Texture2D


func start():
	if not reward: return
	
	ln_input.visible = reward.is_user_input_required
	if icon_img:
		icon.texture = icon_img
	
	title.text = reward.title
	cost.text = str(reward.cost)
	ck_is_active.button_pressed = reward.is_enabled
	#reward.image.url_1x
	#reward.image.url_2x
	#reward.image.url_4x


#func _on_ck_is_active_toggled(toggled_on):
	#if toggled_on == reward.is_enabled: return
	#reward.is_enabled = toggled_on
	#var body := TwitchUpdateCustomRewardBody.from_json(reward.to_dict())
	#body.is_enabled = reward.is_enabled
	#RS.twitcher.api.update_custom_reward(reward.id, body)

func _on_btn_icon_pressed():
	pass # Replace with function body.
	#RS.twitcher.api


#var http_request: HTTPRequest # replace mock
#func _on_btn_test_pressed() -> void:
	#if not http_request:
		#http_request = HTTPRequest.new()
		#add_child(http_request)
	#var img := Image.load_from_file("res://ui/rewards_icons/Activate CoPilot for 5min4.png")
	#update_reward_image(reward.id, img)
#
#
#func update_reward_image(reward_id: String, image: Image) -> void:
	#if not http_request: return
	#if not image: return
#
	#var img_112 = image.duplicate()
	#img_112.resize(112, 112)
	#var img_56 = image.duplicate()
	#img_56.resize(56, 56)
	#var img_28 = image.duplicate()
	#img_28.resize(28, 28)
	#
	#var body := {
		#"operationName": "CreateCommunityPointsImageUploadInfo",
		#"query": """
#mutation CreateCommunityPointsImageUploadInfo($input: CreateCommunityPointsImageUploadInfoInput!) {
#createCommunityPointsImageUploadInfo(input: $input) {
#uploadInfoLarge { uploadID url }
#uploadInfoMedium { uploadID url }
#uploadInfoSmall { uploadID url }
#error { code }
#}
#}
#""",
		#"variables": {
			#"input": {
				#"channelID": RS.settings.broadcaster_id,
				#"customRewardID": reward_id
			#}
		#}
	#}
	#
	#var headers = PackedStringArray([
		#"Authorization: Bearer %s" % await RS.twitcher.service.token.get_access_token(),
		#"Client-Id: kimne78kx3ncx6brgo4mv6wki5h1ko", # Twitch Web Client ID
		#"Content-Type: application/json"
	#])
#
	#var json_body := JSON.stringify(body)
	#var err := http_request.request(
		#"https://gql.twitch.tv/gql",
		#headers,
		#HTTPClient.METHOD_POST,
		#json_body
	#)
	#if err != OK:
		#push_error("GraphQL request failed: %s" % err)
		#return
#
	#var gql_response = await http_request.request_completed
	#var result_code: int = gql_response[0]
	#var status_code: int = gql_response[1]
	#var gql_json: Dictionary = JSON.parse_string(gql_response[3].get_string_from_utf8())
	#print(gql_json) ################ Unauthenticated
	#return ################
	#if gql_json.error != OK:
		#push_error("Failed to parse GraphQL response")
		#return
#
	## Pull out S3 upload URLs
	#var urls = gql_json.result.data.createCommunityPointsImageUploadInfo
	#var uploads = {
		#"small": { "url": urls.uploadInfoSmall.url, "img": img_28 },
		#"medium": { "url": urls.uploadInfoMedium.url, "img": img_56 },
		#"large": { "url": urls.uploadInfoLarge.url, "img": img_112 }
	#}
#
	## Upload each image with raw PUT
	#for size in uploads.keys():
		#var img_bytes = uploads[size]["img"].save_png_to_buffer()
		#var upload_url = uploads[size]["url"]
#
		#var uploader := HTTPRequest.new()
		#add_child(uploader)
		#var upload_headers := PackedStringArray(["Content-Type: image/png"])
		#var put_err := uploader.request_raw(upload_url, upload_headers, HTTPClient.METHOD_PUT, img_bytes)
		#if put_err != OK:
			#push_error("Failed to upload %s image" % size)
			#continue
		#await uploader.request_completed
		#uploader.queue_free()
		#print("Uploaded %s icon!" % size)
