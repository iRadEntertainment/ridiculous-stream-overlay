class_name RSWheelEntry extends Resource


@export var text: String
@export var colour: Color
@export var image: Texture2D
@export var ratio: float


func _init(
		text: String = "",
		colour: Color = Color.WHITE,
		image: Texture2D = null,
		ratio: float = 1.0,
	) -> void:
	self.text = text
	self.colour = colour
	self.image = image
	self.ratio = ratio
